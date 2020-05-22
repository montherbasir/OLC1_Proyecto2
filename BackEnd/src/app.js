var express = require("express");
var cors = require("cors");
var bodyParser = require("body-parser");

let app = express();
app.use(bodyParser.json());
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.post("/parse", async (req, res) => {
    //console.log(req.body.text);
    const text = req.body.text;
    console.log(text);
    res.send({ message: "Compilacion terminada", AST: "ast", errores: parser.errores });
});
// app.post('/parse', function (req, res) {
//     const entrada = req.body.text;
//     var resultado = {AST: "a"};
//     res.send(resultado);
// });
/*---------------------------------------------------------------*/
var server = app.listen(4000, function () {
    console.log('Servidor escuchando en puerto 8080...');
});
/*---------------------------------------------------------------*/
// function parser(texto) {
//     try {
//         return gramatica.parse(texto);
//     } catch (e) {
//         return "Error en compilacion de Entrada: " + e.toString();
//     }
// }