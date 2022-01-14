String humanize(Duration duration) {
  var seconds = duration.inSeconds;

    var minutes = (seconds/60).floor();
    var remaining = seconds % 60;
    return "${minutes > 0 ?  minutes.toString() + " min " : ""}${remaining > 0 ? remaining.toString() + ' sec' : ''}";
}