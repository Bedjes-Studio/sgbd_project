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
        const result = await db.pool.query("DELETE FROM adherent WHERE id_adherent=11");
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

app.get('/api/:table/columns', async (req, res) => {
    try {
        const result = await db.pool.query("show columns from " + req.params.table);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});

// IMPLEMENTS URLS
app.get('/api/stats/users', async (req, res) => {
    try {
        const result = await db.pool.query("select call stat_adherent_par_velo()");
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});


app.get('/api/stats/distance', async (req, res) => {
    try {
        const result = await db.pool.query("select distance_velo_derniere_semaine()");
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});


app.get('/api/stats/totaldistance', async (req, res) => {
    try {
        // classement des vélos les plus chargés par station
        const result = await db.pool.query(`SELECT MIN(KILOMETRAGE_DEPART), KILOMETRAGE FROM (
                                                SELECT KILOMETRAGE_DEPART, ID_VELO FROM EMPRUNT
                                            ) NATURAL JOIN VELO WHERE ID_VELO=2;`);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});


app.get('/api/stats/stations', async (req, res) => {
    try {
        // classement des stations par nombre de bornes disponnibles par commune
        const result = await db.pool.query(`SELECT ADRESSE, NB_BORNES_DISPO, NOM_COMMUNE 
                                            FROM STATION 
                                            JOIN COMMUNE ON COMMUNE=ID_COMMUNE 
                                            ORDER BY NB_BORNES_DISPO, COMMUNE DESC;`);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});

app.get('/api/stats/charge', async (req, res) => {
    try {
        // classement des vélos les plus chargés par station
        const result = await db.pool.query(`SELECT ID_VELO, MARQUE, NIVEAU_BATTERIE, ADRESSE 
                                            FROM VELO 
                                            NATURAL JOIN STATION
                                            ORDER BY ADRESSE, NIVEAU_BATTERIE;`);
        res.setHeader('Content-Type', 'application/json');
        res.json(result);
    } catch (err) {
        throw err;
    }
});

// ##### API ADD #####
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

        switch (req.params.table) {
            case "EMPRUNT":
                await db.pool.query("call creation_emprunt(" + req.body["ID_ADHERENT"] + "," + req.body["ID_VELO"] + ")");
                break;

            case "RENDU":
                await db.pool.query("call rendu_emprunt(" + req.body["ID_STATION"] + "," + req.body["ID_VELO"] + ")");
                break;

            case "DISTANCE":
                await db.pool.query("call distance_station(" + req.body["ID_STATION_1"] + "," + req.body["ID_STATION_2"] + "," + req.body["DISTANCE"] + ")");
                break;

            default:
                await db.pool.query("insert into " + req.params.table + " " + columns + " values " + values);
        }

        res.send("Table updated.");
    } catch (err) {
        res.send("Table not updated : \n" + err);
        throw err;
    }
});

// ##### API DELETE #####
app.delete('/api/:table/:key/:value', async (req, res) => {
    try {
        await db.pool.query("delete from " + req.params.table + " where " + req.params.key + "=" + req.params.value);
        res.send("Table updated.");
    } catch (err) {
        res.send("Table not updated : \n" + err);
        throw err;
    }
});

// ##### API PUT (update) #####
//UPDATE t1 SET c1=c1+1 WHERE c2=(SELECT MAX(c2) FROM t1);

app.put('/api/:table/:key/:value', async (req, res) => {
    try {
        for (let key in req.body) {
            await db.pool.query("update " + req.params.table + " set " + key + "= \"" + req.body[key] + "\" where " + req.params.key + "=" + req.params.value);
        }
        res.send("Table updated.");
    } catch (err) {
        res.send("Table not updated : \n" + err);
        throw err;
    }
});

// 404 
app.get('/*', async (req, res) => {
    res.sendFile('404.html', { root: '.' })
});

app.listen(port, () => console.log(`Listening on port ${port}`));
