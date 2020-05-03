$(function () {
    $.getJSON("lists/last-update.json", function (data) {
        let last_updated = moment.unix(data[0]);
        $('.last-update').html(last_updated.format('YYYY-MM-DD HH:mm'));
    });
});