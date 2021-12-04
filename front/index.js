const express = require('express')
const db = require('./db')
const app = express()
const port = 8080
const bodyParser = require("body-parser");

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// FRONT
app.get('/', async (req, res) => {
    res.sendFile('index.html', { root: '.' })
});

// API LIST
app.get('/api', async (req, res) => {
    try {
        const result = await db.pool.query("select * from commune");
        res.send(result);
    } catch (err) {
        throw err;
    }
});

// ##### API GET #####

// Tables

app.get('/api/table/:table', async (req, res) => {
    try {
        const result = await db.pool.query("select * from " + req.params.table);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});

// ##### API POST #####

app.post('/api/tasks', async (req, res) => {
    let task = req.body;
    try {
        const result = await db.pool.query("insert into tasks (description) values (?)", [task.description]);
        res.send(result);
    } catch (err) {
        throw err;
    }
});

app.put('/tasks', async (req, res) => {
    let task = req.body;
    try {
        const result = await db.pool.query("update tasks set description = ?, completed = ? where id = ?", [task.description, task.completed, task.id]);
        res.send(result);
    } catch (err) {
        throw err;
    }
});

app.delete('/tasks', async (req, res) => {
    let id = req.query.id;
    try {
        const result = await db.pool.query("delete from tasks where id = ?", [id]);
        res.send(result);
    } catch (err) {
        throw err;
    }
});

// 404
app.get('/*', async (req, res) => {
    res.sendFile('404.html', { root: '.' })
});

app.listen(port, () => console.log(`Listening on port ${port}`));
