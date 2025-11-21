# Création de la base de données selon le OS du serveur

## prérequis
Avoir tout son architecture de projet complet + le fichier .env

## Installation de postgreesql

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib
```

## Windows

* Installe **PostgreSQL 17** avec l’installateur officiel (s'assurer que **psql** est inclus).
* Vérifier que `psql.exe` est dans le **PATH** (souvent `C:\Program Files\PostgreSQL\17\bin`).

### Git Bash

* Installer ** Git Bash ** en plus via l’installateur (graphique)

Télécharge Git for Windows (l’installeur standard).

Pendant l’installation, accepte les choix par défaut. À l’étape “Adjusting your PATH environment”, choisis :

## Exécution du script de création selon le OS du serveur

Ouvrir un terminal à la **racine du projet**, ensuite sur :

### Linux / Windows (**avec** Git Bash)

```bash
chmod +x devtools/run_from_zero.sh
./devtools/run_from_zero.sh
```

## Windows (**sans** Git Bash) — PowerShell

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\devtools\run_from_zero.ps1
```


