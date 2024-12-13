const hjson = require("hjson");
const fs = require("fs");

const main = (keyNotFoundCallback, keyFoundCallback) => {
  process.argv.splice(0, 2);
  if (process.argv.length != 2) {
    console.error(
      `this command needs 2 arguments
          - 1: vs code settings filepath
          - 2: the key to check`
    );
    process.exit(1);
  }
  const settingsFilepath = process.argv[0];
  const keyToCheck = process.argv[1];

  try {
    if (!fs.existsSync(settingsFilepath)) {
      console.error(`file ${settingsFilepath} does not exist`);
      process.exit(1);
    }
    const settingsContent = fs.readFileSync(settingsFilepath, "utf8");
    const settings = hjson.rt.parse(settingsContent, {keepWsc: true});

    if (typeof settings[keyToCheck] === "undefined") {
      console.error(
        `file ${settingsFilepath} does not have the key ${keyToCheck}`
      );
      keyNotFoundCallback(settings, keyToCheck);
    } else {
      keyFoundCallback(settings, keyToCheck);
    }
  } catch (err) {
    console.error(err);
    process.exit(2);
  }
};

module.exports = main;
