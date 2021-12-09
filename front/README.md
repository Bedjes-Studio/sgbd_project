# Programmes nécessaires :
- MariaDB ou MySQL
- NodeJS

*versions testées : MariaDB version 10.6.5 et NodeJS version 14.18.1*

# Installation des dépendances :
```bash
# depuis le dossier /front
$ npm install
```

# Créations de la base de données

```bash
# depuis le dossier racine
$ mariadb
# Créez la base de données souhaitée, puis exécutez le fichier make.sql
$ source make.sql
```

*si besoin, créez les utilisateurs nécessaires*

# Lancement du serveur : 

```bash
# depuis le dossier /front
$ npm run build
```

*Ou préférez watch pour un relancement automatique du serveur en cas d'erreur ou de modification des sources*

```bash
# depuis le dossier /front
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

Veillez mettre à jours les informations d'accès à la base en fonction de votre configuration.