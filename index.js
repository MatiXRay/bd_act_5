const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const path = require("path");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// Conexión a MySQL
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    //ACA VA LA CONTRASEÑA DE SQL
    password: '',
    database: 'steamdb'
});

db.connect((err) => {
    if (err) {
        console.error('Error conectando a la base de datos:', err);
    } else {
        console.log('Conectado a MySQL!');
    }
});

// Ruta de login
app.post('/login', (req, res) => {
    const { nombre, contrasenia } = req.body;

    if (!nombre || !contrasenia) {
        return res.status(400).json({ mensaje: 'Faltan datos' });
    }

    const query = 'SELECT * FROM usuarios WHERE nombre = ? AND contrasenia = ?';
    db.query(query, [nombre, contrasenia], (err, results) => {
        if (err) {
            return res.status(500).json({ mensaje: 'Error en la consulta', error: err });
        }

        if (results.length > 0) {
            res.json({ mensaje: 'Login exitoso', usuario: results[0] });
        } else {
            res.status(401).json({ mensaje: 'Usuario o contraseña no existen' });
        }
    });
});

// Endpoint para juegos caros (>20)
app.get("/juegos_caros", (req, res) => {
    db.query("CALL Juegos_Mayores_20()", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0]);
    });
});

// Endpoint para juegos baratos (<=20)
app.get("/juegos_baratos", (req, res) => {
    db.query("CALL Juegos_MenoresIgual_20()", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0]);
    });
});

// Levantar servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
