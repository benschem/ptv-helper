const updateCurrentTime = () => {
  const now = new Date();
  const localTimeString = now.toLocaleTimeString([], {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });

  document.querySelector("#currentTime").innerHTML = `<span class="time">${localTimeString}</span>`;
};

const updateDepartures = () => {
  departures = document.querySelectorAll(".departure");

  departures.forEach((departure) => {
    const time = departure.querySelector(".departure-time");
    const departureTime = new Date(time.dataset.departureTime);
    const now = new Date();
    const remainingTime = departureTime - now;
    const timeRemaining = departure.querySelector(".time-to-departure > span");
    const minutesRemaining = Math.ceil(remainingTime / 60000);
    timeRemaining.innerText = minutesRemaining;

    if (timeRemaining.innerText > 0) {
    } else if (timeRemaining.innerText == 0) {
      timeRemaining.innerText = "NOW";
    } else if (timeRemaining.innerText < 0) {
      departure.parentElement.remove();
    }
  });
};

window.addEventListener("DOMContentLoaded", () => {
  window.setInterval(updateCurrentTime, 1000);
  window.setInterval(updateDepartures, 1000);
});
