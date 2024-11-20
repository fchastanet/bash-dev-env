const main = require("./getSettingFromKey");

main(
  () => {
    // ignore error
    process.exit(0);
  },
  (settings, keyToCheck) => {
    let extensions = [];
    for (var key in settings[keyToCheck]) {
      if (Object.prototype.hasOwnProperty.call(settings[keyToCheck], key)) {
        if (Array.isArray(settings[keyToCheck][key]?.extensions)) {
          extensions = extensions.concat(settings[keyToCheck][key].extensions);
        }
      }
    }
    extensions = [...new Set(extensions)];
    extensions.forEach((ext) => {
      console.log(ext);
    });
    process.exit(0);
  }
);
