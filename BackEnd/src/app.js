var express = require("express");
var cors = require("cors");
var bodyParser = require("body-parser");
var parser = require("./gramatica");

let app = express();

app.use(bodyParser.json());
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.post("/parse", async (req, res) => {
    //console.log(req.body.text);
    const text = req.body.text;
    //console.log(text);
    let x = {};
    try{
       x = parser.parse(text);
    }catch(e){
        x = {"AST": {}, "errores":[{"valor":e.toString()}]};
    }
    res.send(x);
});
// app.post('/parse', function (req, res) {
//     const entrada = req.body.text;
//     var resultado = {AST: "a"};
//     res.send(resultado);
// });
/*---------------------------------------------------------------*/
var server = app.listen(4000, function () {
    console.log('Servidor escuchando en puerto 4000...');
});
/*---------------------------------------------------------------*/
// function parser(texto) {
//     try {
//         return gramatica.parse(texto);
//     } catch (e) {
//         return "Error en compilacion de Entrada: " + e.toString();
//     }
// }