import { small_nft } from "../../declarations/small_nft";

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  // Interact with small_nft actor, calling the greet method
  const greeting = await small_nft.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
