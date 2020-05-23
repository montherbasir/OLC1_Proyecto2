function Analizar() {

}

function dld() {
    download(ace.edit("editorP").getValue(), "Python.py");
}

document.getElementById('input-file').onchange = function () {
    getFile(1);
};

document.getElementById('input-file2').onchange = function () {
    getFile(2);
};


function getFile(n) {
    let input = document.getElementById("input-file");
    if (n === 2) {
        input = document.getElementById("input-file2");
    }
    if ('files' in input && input.files.length > 0) {
        placeFileContent(input.files[0], n);
        console.log(input.value)
    }
}

function placeFileContent(file, n) {
    readFileContent(file).then(content => {
        if (n === 1) {
            ace.edit("editor 1").setValue(content);
        } else if (n === 2) {
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

function printError(errores) {
    var session = ace.edit("editorH").session;
    errores.forEach(err => {
        session.insert({
            row: session.getLength(),
            column: 0
        }, err.valor + "\n");
    });
}

document.getElementById('parse').onclick = async function () {
    const res = await postData(ace.edit("editor 1").getValue());
    console.log(res);
    printError(res.errores);
};

document.getElementById('limpiar').onclick = function(){
    ace.edit("editorH").setValue("");
}

async function postData(txt) {
    let url = "http://localhost:4000/parse";
    const data = {text: txt};

    const res = await fetch(url, {
        method: 'POST', // or 'PUT'
        body: JSON.stringify(data), // data can be `string` or {object}!
        headers: {
            'Content-Type': 'application/json'
        }
    }).catch(error => console.error('Error:', error));

    const json = await res.json();
    document.getElementById("tree").innerHTML = "";
    var render = renderjson(json.AST);
    document.getElementById("tree").appendChild(render);
    return json;
}






