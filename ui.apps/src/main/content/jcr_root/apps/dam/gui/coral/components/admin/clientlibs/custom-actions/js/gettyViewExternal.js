$(document).on("foundation-contentloaded", function(e) {
    var gettyViewExternalActivator = ".my-damadmin-admin-actions-getty-viewexternal-activator";

    $(document).off("click", gettyViewExternalActivator).on("click", gettyViewExternalActivator, function(e) {
        var gettyId = $(".foundation-selections-item").map(function() {
            return $(".foundation-collection-assets-meta", this).data("getty-id");
        }).get()[0];

        var gettyUrl = "https://www.gettyimages.com/detail/" + gettyId;

        window.open(gettyUrl, '_blank').focus();
    });
});