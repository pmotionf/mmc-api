const fs = require("fs").promises;

module.exports = async ({ core }, name, path) => {
  // Parse the file provided by path to get the version.
  let version;
  const raw = await fs.readFile(path);
  const lines = raw.toString().split("\n");
  lines.forEach((line) => {
    line = line.trim();
    const version_idx = line.search("SemanticVersion.parse");
    if (version_idx != -1) {
      const parts = line.split('"');
      version = parts[1];
    }
  });

  core.exportVariable("NAME", name);
  core.exportVariable("VERSION", version);
};
