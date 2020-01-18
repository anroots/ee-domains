function appendRow(domain, action) {
    let link = '<a href="//' + domain + '" target="_blank">' + domain + '</a>';
    let badgeClass = action === 'ADDED' ? 'success' : 'danger';
    let newTableRow = '<tr><td>' + link + '</td><td><span class="badge badge-' + badgeClass + '">'+action+'</span></td></tr>';
    $('#timeline-table tr:last').after(newTableRow);
}

function appendTimeline(monthData) {
    $.each(monthData, function (day, domainData) {
        let time = moment.unix(domainData['timestamp']);
        $('#timeline-table tr:last').after('<tr><th colspan="2" class="table-dark text-center">' + time.format('YYYY-MM-DD') + '</th></tr>');

        $.each(domainData['added'], function (k, v) {
            appendRow(v, 'ADDED');
        });

        $.each(domainData['deleted'], function (k, v) {
            appendRow(v, 'DELETED');
        });
    });
}


$(function () {
    $.getJSON("lists/last-update.json", function (data) {
        let last_updated = moment.unix(data[0]);
        $('.last-update').html(last_updated.format('YYYY-MM-DD HH:mm'));
    });

    let year = moment().format('YYYY');
    let month = moment().subtract(1, 'month').format('MM');
    let prevMonth = moment().format('MM');

    $.getJSON("lists/" + year + "/" + prevMonth + ".json", function (domainData) {
        appendTimeline(domainData);
    });

    $.getJSON("lists/" + year + "/" + month + ".json", function (domainData) {
        appendTimeline(domainData);
    });
});