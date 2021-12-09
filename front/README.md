# Programmes nécessaires :
- MariaDB ou MySQL
- NodeJS

*versions testées : MariaDB version 10.6.5 et NodeJS version 14.18.1*

# Installation des dépendances :
```bash
$ npm install
```

# Créations de la base de données

```bash
$ mariadb
$ source make.sql
```

*si besoin, créez les utilisateurs nécessaires*

# Lancement du serveur : 

```bash
$ cd ./front
$ npm run build
```

*Ou préférez watch pour un relancement automatique du serveur en cas d'erreur ou de modification des sources*

```bash
$ npm run watch
```

# configuration par défaut :

Pour que NodeJS puisse intéragir avec la base, il est nécessaire de remplir correctement le fichier */front/db.js*. La configuration par défaut est :

```js
mariadb.createPool({
    host: "127.0.0.1", 
    port: 3306,
    user: "root", 
    password: "",
    database: "projet"
});
```
