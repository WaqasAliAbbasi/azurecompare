'use strict';

var g_app_initialized = false;
var g_data_table = null;
var g_settings = {};
var totalSelected = parseInt(0);
var clickedQuantity = false;
var selectedItems = {};

var g_settings_defaults = {
    cost_duration: 'hourly',
    region: 'AP Southeast',
    min_memory: 0,
    min_cores: 0,
    min_storage: 0,
    selected: ''
};

function init_data_table() {
    g_data_table = $('#data').DataTable({
        "select": true,
        "bPaginate": false,
        "bInfo": false,
        "bStateSave": true,
        "oSearch": {
            "bRegex": true,
            "bSmart": false
        },
        "aoColumnDefs": [
            {
                // The columns below are sorted according to the sort attr of the <span> tag within their data cells
                "aTargets": [
                    "memory",
                    "cores",
                    "storage",
                    "cost"
                ],
                "sType": "span-sort"
            },
            {
                // The columns below are hidden by default
                "aTargets": [
                    "gpus",
                    "cost linux-low-priority",
                    "cost windows-low-priority",
                    "cost msft-r-server-linux",
                    "cost biztalk- standard",
                    "cost biztalk-enterprise",
                    "cost oracle-java",
                    "cost redhat-enterprise-linux",
                ],
                "bVisible": false
            },
            { "width": "5%", "targets": 1 }
        ],
        // default sort by linux cost
        "aaSorting": [
            [6, "asc"]
        ],
        'initComplete': function () {
            // fire event in separate context so that calls to get_data_table()
            // receive the cached object.
            setTimeout(function () {
                on_data_table_initialized();
            }, 0);
        },
        'drawCallback': function () {
            // abort if initialization hasn't finished yet (initial draw)
            if (g_data_table === null) {
                return;
            }

            // Whenever the table is drawn, update the costs. This is necessary
            // because the cost duration may have changed while a filter was being
            // used and so some rows will need updating.
            redraw_costs();
        },
        // Store filtering, sorting, etc - core datatable feature
        'stateSave': true,
        // Allow export to CSV
        buttons: [{
            extend: 'csv',
            text: 'Export Selected to CSV',
            action: function (e, dt, button, config) {
                // Add code to make changes to table here
                var dta = $("#data").DataTable();
                dta.rows('.highlight').select();
                // Call the original action function afterwards to
                // continue the action.
                // Otherwise you're just overriding it completely.
                $.fn.dataTable.ext.buttons.csvHtml5.action(e, dt, button, config);
            },
                exportOptions: {
                    rows: { selected: true },
                    columns: ":not(:nth-child(2))"
                }
        }
        ]
    });

    g_data_table
        .buttons()
        .container()
        .find('a')
        .addClass('btn btn-primary')
        .appendTo($('#menu > div'));

    return g_data_table;
}

$(document).ready(function () {
    init_data_table();
});


function change_cost(duration) {
    // update menu text
    var first = duration.charAt(0).toUpperCase();
    var text = first + duration.substr(1);
    $("#cost-dropdown .dropdown-toggle .text").text(text);

    // update selected menu option
    $('#cost-dropdown li a').each(function (i, e) {
        e = $(e);
        if (e.attr('duration') == duration) {
            e.parent().addClass('active');
        } else {
            e.parent().removeClass('active');
        }
    });

    var hour_multipliers = {
        "hourly": 1,
        "daily": 24,
        "weekly": (7 * 24),
        "monthly": (365 * 24 / 12),
        "annually": (365 * 24)
    };
    var multiplier = hour_multipliers[duration];
    var per_time;

    $.each($("td.cost"), function (i, elem) {
        elem = $(elem);
        per_time = elem.data("pricing")[g_settings.region];
        if (per_time && !isNaN(per_time)) {
            per_time = (per_time * multiplier).toFixed(3);
            elem.empty();
            elem.append('<span sort="' + per_time + '">$' + per_time + ' ' + duration + '</span>');
        } else {
            elem.empty();
            elem.append('<span sort="99999999">unavailable</span>');
        }
    });

    g_settings.cost_duration = duration;
    update_selections();
    maybe_update_url();
}

function change_region(region) {
    g_settings.region = region;
    var region_name = null;
    $('#region-dropdown li a').each(function (i, e) {
        e = $(e);
        if (e.data('region') === region) {
            e.parent().addClass('active');
            region_name = e.text();
        } else {
            e.parent().removeClass('active');
        }
    });
    $("#region-dropdown .dropdown-toggle .text").text(region_name);
    change_cost(g_settings.cost_duration);
    g_data_table.rows().invalidate().draw();

}

// Update all visible costs to the current duration.
// Called after new columns or rows are shown as their costs may be inaccurate.
function redraw_costs() {
    change_cost(g_settings.cost_duration);
}

function setup_column_toggle() {
    $.each(g_data_table.columns().indexes(), function (i, idx) {
        var column = g_data_table.column(idx);
        $("#filter-dropdown ul").append(
            $('<li>')
                .toggleClass('active', column.visible())
                .append(
                $('<a>', { href: "javascript:;" })
                    .text($(column.header()).text())
                    .click(function (e) {
                        toggle_column(i);
                        $(this).parent().toggleClass("active");
                        $(this).blur(); // prevent focus style from sticking in Firefox
                        e.stopPropagation(); // keep dropdown menu open
                    })
                )
        );
    });
}

function setup_clear() {
    $('.btn-clear').click(function () {
        // Reset app.
        g_settings = JSON.parse(JSON.stringify(g_settings_defaults)); // clone
        clear_row_selections();
        selectedItems = {};
        maybe_update_url();
        store.clear();
        g_data_table.state.clear();
        window.location.reload();     
    });
}

function clear_row_selections() {
    $('#data tbody tr').removeClass('highlight');
}

function url_for_selections() {
    var params = {
        min_memory: g_settings.min_memory,
        min_cores: g_settings.min_cores,
        min_storage: g_settings.min_storage,
        filter: g_data_table.settings()[0].oPreviousSearch['sSearch'],
        region: g_settings.region,
        cost_duration: g_settings.cost_duration,
    };

    // avoid storing empty or default values in URL
    for (var key in params) {
        if (params[key] === '' || params[key] == null || params[key] === g_settings_defaults[key]) {
            delete params[key];
        }
    }

    var selected_row_ids = Object.keys(selectedItems).map(function (key) {
        var q = parseInt(selectedItems[key]);
        if (isNaN(q)) {
            q = 0;
        }
        return key + ":" + q;
    });

    if (selected_row_ids.length > 0) {
        params.selected = selected_row_ids;
    }

    var url = location.origin + location.pathname;
    var parameters = [];
    for (var setting in params) {
        if (params[setting] !== undefined) {
            parameters.push(setting + '=' + params[setting]);
        }
    }
    if (parameters.length > 0) {
        url = url + '?' + parameters.join('&');
    }
    return url;
}

function maybe_update_url() {
    // Save localstorage data as well
    store.set('azurevm_settings', g_settings);

    if (!history.replaceState) {
        return;
    }

    try {
        var url = url_for_selections();
        if (document.location == url) {
            return;
        }

        history.replaceState(null, '', url);
    } catch (ex) {
        // doesn't matter
    }
}

var apply_min_values = function () {
    var all_filters = $('[data-action="datafilter"]');
    var data_rows = $('#data tr:has(td)');

    data_rows.show();

    all_filters.each(function () {
        var filter_on = $(this).data('type');
        var filter_val = parseFloat($(this).val()) || 0;

        // update global variable for dynamic URL
        g_settings["min_" + filter_on] = filter_val;

        var match_fail = data_rows.filter(function () {
            var row_val;
            row_val = parseFloat(
                $(this).find('td[class~="' + filter_on + '"] span').attr('sort')
            );
            return row_val < filter_val;
        });

        match_fail.hide();
        data_rows.filter('#total').show();
    });
    maybe_update_url();
};

function on_data_table_initialized() {
    if (g_app_initialized) return;
    g_app_initialized = true;

    load_settings();
    // populate filter inputs
    $('[data-action="datafilter"][data-type="memory"]').val(g_settings['min_memory']);
    $('[data-action="datafilter"][data-type="cores"]').val(g_settings['min_cores']);
    $('[data-action="datafilter"][data-type="storage"]').val(g_settings['min_storage']);
    apply_min_values();

    // apply highlight to selected rows
    $.each(g_settings.selected.split(','), function (_, id) {
        var urlquantity = id.split(':')[1];
        id = id.split(':')[0];
        id = id.replace('.', '\\.');
        if (id != '') {
            selectedItems[id] = urlquantity;
            $($("#data").DataTable().row("#" + id).node()).addClass('highlight');
            $($("#data").DataTable().row("#" + id).node()).find('input').val(urlquantity);
        }
    });

    configure_highlighting();

    // Allow row filtering by min-value match.
    $('[data-action=datafilter]').on('keyup', apply_min_values);

    change_region(g_settings.region);
    change_cost(g_settings.cost_duration);

    $.extend($.fn.dataTableExt.oStdClasses, {
        "sWrapper": "dataTables_wrapper form-inline"
    });

    setup_column_toggle();

    setup_clear();

    // enable bootstrap tooltips
    $('abbr').tooltip({
        placement: function (tt, el) {
            return (this.$element.parents('thead').length) ? 'top' : 'right';
        }
    });

    $("#cost-dropdown li").bind("click", function (e) {
        change_cost(e.target.getAttribute("duration"));
    });

    $("#region-dropdown li.available").bind("click", function (e) {
        change_region($(e.target).data('region'));
    });

    // apply classes to search box
    $('div.dataTables_filter input').addClass('form-control search');
}

// sorting for colums with more complex data
// http://datatables.net/plug-ins/sorting#hidden_title
jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "span-sort-pre": function (elem) {
        var matches = elem.match(/sort="(.*?)"/);
        if (matches) {
            return parseFloat(matches[1]);
        }
        return 0;
    },

    "span-sort-asc": function (a, b) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "span-sort-desc": function (a, b) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
});

// toggle columns
function toggle_column(col_index) {
    var is_visible = g_data_table.column(col_index).visible();
    g_data_table.column(col_index).visible(is_visible ? false : true);
    redraw_costs();
}

// retrieve all the parameters from the location string
function load_settings() {
    if (!((window.location.href).indexOf("withaws") !== -1)) {
        // load settings from local storage
        g_settings = store.get('azurevm_settings') || {};

        if (location.search) {
            var params = location.search.slice(1).split('&');
            params.forEach(function (param) {
                var parts = param.split('=');
                var key = parts[0];
                var val = parts[1];
                // support legacy key names
                if (key == 'cost') {
                    key = 'cost_duration';
                } else if (key == 'term') {
                    key = 'reserved_term';
                }
                // store in global settings
                //console.log('loaded from url', key, decodeURI(val));
                g_settings[key] = decodeURI(val);
            });
        }

        // use default settings for missing values
        for (var key in g_settings_defaults) {
            if (g_settings[key] === undefined) {
                g_settings[key] = g_settings_defaults[key];
            }
        }     
    }
    else
    {
        g_settings = g_settings_defaults;
    }
    return g_settings;
}

function configure_highlighting() {
    var compareOn = false,
        $compareBtn = $('.btn-compare'),
        $rows = $('#data tbody tr');

    $("td.quantity").on('click', function () {
        clickedQuantity = true;
        setTimeout(function () {
            clickedQuantity = false;
        }, 100);
    });

    // Allow row highlighting by clicking.
    $rows.click(function () {
        if (!clickedQuantity) {
            var id = $(this).attr("id");
            var quantity = parseInt($($("#data").DataTable().row("#" + id).node()).find('input').val());
            if (isNaN(quantity) || quantity == '') {
                quantity = parseInt(0);
            }
            if ($(this).hasClass('highlight')) {              
                delete selectedItems[id];
            }
            else {
                selectedItems[id] = quantity;
            }
            console.log(id);
            $($("#data").DataTable().row("#" + id).node()).toggleClass('highlight');

            if (!compareOn) {
                $compareBtn.prop('disabled', !$rows.is('.highlight'));
            }
            update_selections();
            maybe_update_url();
        }
        else
        {
            clickedQuantity = false;
        }
    });

    $compareBtn.prop('disabled', !$($rows).is('.highlight'));
    $compareBtn.text($compareBtn.data('textOff'));

    $compareBtn.click(function () {
        if (compareOn) {
            $rows.show();
            $compareBtn.text($compareBtn.data('textOff'))
                .addClass('btn-primary')
                .removeClass('btn-success')
                .prop('disabled', !$rows.is('.highlight'));
        } else {
            $rows.filter(':not(.highlight)').hide();
            $compareBtn.text($compareBtn.data('textOn'))
                .addClass('btn-success')
                .removeClass('btn-primary');
        }

        compareOn = !compareOn;
    });

    $.each($("#data").DataTable().rows("tr.highlight"), function (i, index) {
        $($("#data").DataTable().rows("tr.highlight").row(index).node()).find("input").on("change paste keyup", function () {
            if ($(this).val() != '' && !(Math.floor($(this).val()) == $(this).val() && $.isNumeric($(this).val()))) {
                $(this).val(parseInt(toString(Math.floor($(this).val())).replace(/^0+/, '0')));
            }
            $(this).val($(this).val().replace(/^0+/, ''));
            var quantity = parseInt($(this).val());
            console.log(selectedItems);
            if (isNaN(quantity) || quantity == '') {
                quantity = parseInt(0);
            }
            selectedItems[$(this).parent().parent().attr('id')] = quantity;
            console.log(selectedItems);
            update_selections();
            maybe_update_url();
        });
    });

    $("td.quantity input").on("change paste keyup", function () {
        if ($(this).val() != '' && !(Math.floor($(this).val()) == $(this).val() && $.isNumeric($(this).val()))) {
            $(this).val(parseInt(toString(Math.floor($(this).val())).replace(/^0+/, '0')));
        }
        $(this).val($(this).val().replace(/^0+/, ''));
        var quantity = parseInt($(this).val());
        if (isNaN(quantity) || quantity == '') {
            quantity = parseInt(0);
        }
        selectedItems[$(this).parent().parent().attr('id')] = quantity;
        update_selections();
        maybe_update_url();
    });
}

function update_selections() {
    if (!isNaN(Object.values(selectedItems).reduce(add, 0))) {
        totalSelected = Object.values(selectedItems).reduce(add, 0);
        var elemTotalName = $($('#total').find("th.name"));
        elemTotalName.text('Total (' + totalSelected + ' Selected)');

        $.each($($("#data").DataTable().table().header()).find('#total').find("th.total-cost"), function (i, elemTotal) {
            var elemTotal = $(elemTotal);
            elemTotal.empty();
            elemTotal.append('<span total="0">$0.000 ' + g_settings_defaults.cost_duration + '</span>');
        });

        if (Object.keys(selectedItems).length > 0) {
            $.each(Object.keys(selectedItems), function (i, id) {
                $.each($($("#data").DataTable().row("#" + id).node()).find("td.cost"), function (k, elem) {
                    elem = $(elem);
                    var elemTotal = $($($("#data").DataTable().table().header()).find('#total').find("th.total-cost")[k]);
                    var value2 = 0;
                    if (elem.find('span').attr('sort') != '99999999') {
                        value2 = parseFloat(elem.find('span').attr('sort')) * selectedItems[id];
                    }
                    var value = parseFloat(elemTotal.find('span').attr('total')) + value2;
                    value = Math.round(value * 1000) / 1000;
                    elemTotal.empty();
                    elemTotal.append('<span total="' + value.toFixed(3) + '">$' + value.toFixed(3) + ' ' + g_settings_defaults.cost_duration + '</span>');
                });
            });
        }
    }
}
        
function add(a, b) {
    return parseInt(a) + parseInt(b);
}