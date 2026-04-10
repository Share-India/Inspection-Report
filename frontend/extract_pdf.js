const { fromPath } = require("pdf2pic");
const path = require("path");

const options = {
    density: 300,
    saveFilename: "pdf_page",
    savePath: "./images",
    format: "png",
    width: 2480,
    height: 3508
};

const storeAsImage = fromPath(path.resolve(__dirname, "R000015387.pdf"), options);

storeAsImage(1).then((resolve) => {
    console.log("Page 1 is now converted as image");
    return storeAsImage(2);
}).then((resolve) => {
    console.log("Page 2 is now converted as image");
});
