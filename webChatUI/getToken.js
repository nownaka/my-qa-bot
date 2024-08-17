async function getToken(userName) {
  // Fetch token from your server
  const response = await fetch(
    "https://directline.botframework.com/v3/directline/tokens/generate",
    {
      method: "POST",
      headers: {
        Authorization: "Bearer " + "<your direct line secret>",
      },
      json: {
        user: { id: `dl_${userName}`, name: userName },
      },
    }
  );
  const { token } = await response.json();
  return token;
}
