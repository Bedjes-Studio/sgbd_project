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
        const result = await db.pool.query("call creation_emprunt(1,1)");
        res.send(result);
    } catch (err) {
        throw err;
    }
});

// ##### API GET #####

// Tables

app.get('/api/:table', async (req, res) => {
    try {
        const result = await db.pool.query("select * from " + req.params.table);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});

// ##### API POST #####
function parseData(data) {
    let values = "(";
    let columns = "(";

    for (let key in data) {
        columns += "\`" + key + "\`,";
        values += "\"" + data[key] + "\",";
    }
    columns = columns.slice(0, -1); // remove last comma
    values = values.slice(0, -1); // remove last comma

    columns += ")";
    values += ")";
    return { columns, values };
}

app.post('/api/:table/add', async (req, res) => {
    try {
        let { columns, values } = parseData(req.body);
        console.log(columns);
        console.log(values);
        await db.pool.query("insert into " + req.params.table + " " + columns + " values " + values);
        res.send("Table updated.");
    } catch (err) {
        res.send("Table not updated : \n" + err);
        throw err;
    }
});

// ##### API PUT (update) #####

// TODO : implements this api
app.put('/', async (req, res) => {

});

// ##### API DELETE #####

// TODO : implements this api
app.delete('/', async (req, res) => {

});

// 404 
app.get('/*', async (req, res) => {
    res.sendFile('404.html', { root: '.' })
});

app.listen(port, () => console.log(`Listening on port ${port}`));
