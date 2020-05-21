

function Analizar(){

}

function dld(){
    download(ace.edit("editorP").getValue(),"Python.py");
}
document.getElementById('input-file').onchange = function () {
    getFile(1);
};

document.getElementById('input-file2').onchange = function () {
    getFile(2);
};

function getFile(n) {
    let input = document.getElementById("input-file");
    if(n===2){
        input = document.getElementById("input-file2");
    }
    if ('files' in input && input.files.length > 0) {
        placeFileContent(input.files[0], n);
        console.log(input.value)
    }
}

function placeFileContent(file, n) {
    readFileContent(file).then(content => {
        if(n===1){
            ace.edit("editor 1").setValue(content);
        }else if(n===2){
            ace.edit("editor 2").setValue(content);
        }
    }).catch(error => console.log(error));
}

function readFileContent(file) {
    const reader = new FileReader();
    return new Promise((resolve, reject) => {
        reader.onload = event => resolve(event.target.result);
        reader.onerror = error => reject(error);
        reader.readAsText(file);
    })
}








