$(document).ready(function(){
    setInterval(() => {
        let date = new Date();
        $("#real-time").text(date.toLocaleTimeString('pt-PT'));
    }, 1000);

    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.action === "open") {
            $("#ui-container").fadeIn(200);
            $("#cam-label").text(data.label);
            $("#current-cam-name").text(data.camName);
        }
    });

    $("#next").click(() => changeCam("next"));
    $("#prev").click(() => changeCam("prev"));

    function changeCam(dir) {
        $.post('https://cocaine-cctv/change', JSON.stringify({ direction: dir }), function(newName){
            $("#current-cam-name").text(newName);
        });
    }

    $("#close").click(function() {
        $("#ui-container").fadeOut(200);
        $.post('https://cocaine-cctv/close', JSON.stringify({}));
    });
});