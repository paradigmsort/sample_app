function saveLength() {
  var textArea = document.getElementById("micropost_content");
  var remainingElement = document.getElementById("count_remaining");
  var length = textArea.value.length;
  var remaining = 140 - length;
  remainingElement.innerHTML = remaining.toString();
}

window.onload = function () {
  var textArea = document.getElementById("micropost_content");
  textArea.onkeyup = saveLength;
}
