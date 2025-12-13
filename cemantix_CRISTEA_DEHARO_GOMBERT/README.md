# Cemantix IA - README Complet

## 📋 Vue d'ensemble

**Cemantix IA** est une application web complète pour jouer au jeu Cemantix (trouver un mot cible basé sur la similarité sémantique) avec support d'IA. Le projet est composé de trois parties :

- **Backend** : API FastAPI en Python (gestion du jeu, calcul de similarité, IA)
- **Frontend** : Interface Angular moderne
- **IA** : Modules de résolution automatique (TF-IDF, Sentence Transformers, LLM)

---

## 🎮 Fonctionnement

### Jeu Cemantix
1. Un mot cible est sélectionné aléatoirement
2. Le joueur (ou l'IA) propose des mots
3. Chaque mot reçoit un score de similarité (0-100) par rapport au mot cible
4. L'objectif : trouver le mot cible

### Modes d'IA disponibles

| Mode | Variable d'env | Qualité | Vitesse | Poids |
|------|----------------|---------|---------|-------|
| **TF-IDF** | `USE_ST_MODEL=0` | Basique | ⚡ Rapide | Léger |
| **Sentence Transformers** | `USE_ST_MODEL=1` | 🌟 Excellente | Moyen | Lourd (~500MB) |
| **LLM (Llama)** | Détecté auto | 🚀 Optimale | Lent | Très lourd |

---

## 🛠️ Installation et mise en place

### Prérequis
- **Python 3.11+** (installez depuis https://www.python.org/downloads/)
- **Node.js 18+** (pour le frontend Angular)
- **Git**

### 1️⃣ Backend (FastAPI)

```bash
# Naviguer au dossier backend
cd backend

# Créer et activer l'environnement virtuel
python -m venv .venv
.\.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/macOS

# Installer les dépendances
pip install -r requirements.txt
```

#### Modèles spaCy disponibles

Le modèle spaCy détermine la qualité du calcul de similarité sémantique. Vous avez le choix entre 3 tailles :

| Modèle | Taille | Qualité | Vitesse | Recommandation |
|--------|--------|---------|---------|----------------|
| `fr_core_news_sm` | ~40 MB | Basique | ⚡ Très rapide | Tests rapides |
| `fr_core_news_md` | ~100 MB | Bonne | ⚡ Rapide | Équilibre |
| `fr_core_news_lg` | ~500 MB | 🌟 Excellente | Normal | **Recommandé** |

**Installation du modèle** :
```bash
# Télécharger et installer le modèle (choisissez 1)
python -m spacy download fr_core_news_lg    # Recommandé (meilleure qualité)
# python -m spacy download fr_core_news_md  # Bon équilibre
# python -m spacy download fr_core_news_sm  # Léger / rapide
```

**Adaptation dans game.py** :

Modifiez la ligne 9 du fichier [`backend/app/game.py`](backend/app/game.py) :

```python
# Changez selon le modèle que vous avez téléchargé
nlp = spacy.load("fr_core_news_lg")    # Recommandé
# nlp = spacy.load("fr_core_news_md")  # Alternatif
# nlp = spacy.load("fr_core_news_sm")  # Léger
```

**Lancer le serveur** :
```bash
$env:USE_ST_MODEL = "1"  # Windows : Active Sentence Transformers
export USE_ST_MODEL=1    # Linux/macOS
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Le backend sera accessible à `http://127.0.0.1:8000`

**Documentation API** : `http://127.0.0.1:8000/docs` (Swagger)

### 2️⃣ Frontend (Angular)

```bash
# Naviguer au dossier frontend
cd frontend/cemantix-fr

# Installer les dépendances
npm install

# Lancer le serveur de développement
ng serve

# Ou pour le build production
ng build
```

Le frontend sera accessible à `http://localhost:4200`

### 3️⃣ IA (Résolution automatique)

```bash
# Depuis le dossier IA
cd IA

# Activer le venv du backend (pour les dépendances partagées)
.\..\backend\.venv\Scripts\activate

# Lancer le solveur IA
python main.py
```

---

## 🚀 Démarrage rapide (tous les composants)

### Windows
```powershell
# Terminal 1 - Backend
cd backend
.\.venv\Scripts\activate
$env:USE_ST_MODEL = "1"
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

# Terminal 2 - Frontend
cd frontend/cemantix-fr
npm install
ng serve

# Terminal 3 - IA (optionnel)
cd IA
python main.py
```

### Linux/macOS
```bash
# Terminal 1 - Backend
cd backend
source .venv/bin/activate
export USE_ST_MODEL=1
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

# Terminal 2 - Frontend
cd frontend/cemantix-fr
npm install
ng serve

# Terminal 3 - IA (optionnel)
cd IA
python main.py
```

---

## 📡 Architecture Backend

### Fichiers clés

| Fichier | Rôle |
|---------|------|
| `app/main.py` | Application FastAPI principale, endpoints |
| `app/game.py` | Logique du jeu (scoring, gestion des parties) |
| `app/ai_solver.py` | IA légère (TF-IDF + spaCy) |
| `app/ai_solver_llm.py` | IA avancée (Sentence Transformers + LLM) |
| `app/vocab.txt` | Vocabulaire français (~50k mots) |

### Endpoints API

#### 🎮 Gestion du jeu
- **POST** `/start` → Démarre une nouvelle partie
  ```json
  { "target": "optional_word" }
  ```
  Réponse : `{ "game_id": "...", "vocab_size": 50000 }`

- **POST** `/guess` → Envoie une proposition
  ```json
  { "game_id": "...", "guess": "mot" }
  ```
  Réponse : `{ "score": 85, "rank": 12, "found": false, "similar_words": [...] }`

- **GET** `/vocab` → Récupère une partie du vocabulaire
  ```json
  { "words": ["mot1", "mot2", ...], "count": 100 }
  ```

#### 🤖 IA
- **POST** `/ai/suggest` → Obtient la suggestion de l'IA
- **GET** `/ai/status` → État de l'IA active

#### 📊 Debug
- **GET** `/health` → Santé du serveur

---

## 🧠 Modules IA

### `ai_solver.py` - Léger (TF-IDF)
- Rapide, peu de mémoire
- Basé sur la fréquence des termes
- Bon pour tester rapidement
- **Commande** : `USE_ST_MODEL=0`

### `ai_solver_llm.py` - Avancé (Sentence Transformers + LLM)
- Comprend le sens sémantique des mots
- Modèle pré-entraîné français
- Meilleure qualité de prédiction
- **Commande** : `USE_ST_MODEL=1`

### [`IA/seeking_word.py`](IA/seeking_word.py) - Solveur autonome
Implémente une stratégie d'exploration intelligente :
1. Propose des mots basés sur la similarité
2. Affine la recherche selon les retours
3. Converge vers le mot cible

---

## 🎨 Architecture Frontend (Angular)

### Structure
```
src/
├── app/
│   ├── app.component.ts      # Composant principal
│   ├── app.component.html    # Template
│   ├── app.component.scss    # Styles
│   ├── api.service.ts        # Service HTTP vers le backend
│   └── app.routes.ts         # Routage
├── main.ts                    # Point d'entrée
└── styles.css                 # Styles globaux
```

### Flux utilisateur
1. Interface affiche un formulaire de saisie
2. Appel `POST /guess` au backend
3. Reçoit le score et la liste de mots similaires
4. Mise à jour dynamique de l'affichage
5. Victoire si score = 100

---

## ⚙️ Configuration

### Variables d'environnement

#### Backend
- `USE_ST_MODEL` : `0` (TF-IDF) ou `1` (Sentence Transformers)
  ```powershell
  $env:USE_ST_MODEL = "1"  # Windows
  export USE_ST_MODEL=1    # Linux/macOS
  ```

- `MODEL_PATH` : Chemin du modèle spaCy (détecté auto)

- `VOCAB_PATH` : Chemin du fichier vocabulaire (par défaut : `app/vocab.txt`)

#### Frontend
- Configuré dans `src/environments/`
- URL du backend : `http://127.0.0.1:8000` (à adapter si nécessaire)

---

## 🐛 Dépannage

### Erreur : "Can't find model 'fr_core_news_lg'"
```bash
python -m spacy download fr_core_news_lg
```
Puis mettez à jour [`backend/app/game.py`](backend/app/game.py) ligne 9 avec le modèle téléchargé.

### Erreur : "SSL module not available"
Réinstallez Python 3.11+ depuis https://www.python.org/downloads/
- ✅ Cochez "Install certificates"
- ✅ Cochez "Add Python to PATH"

### Erreur : "Port 8000 déjà utilisé"
```bash
uvicorn app.main:app --reload --host 127.0.0.1 --port 8001
```

### Frontend : CORS error
Vérifiez que le backend tourne sur `http://127.0.0.1:8000`

### IA lente au premier lancement
Les modèles Sentence Transformers se téléchargent (~500MB). C'est normal.

---

## 📚 Documentation supplémentaire

| Resource | Lien |
|----------|------|
| FastAPI | https://fastapi.tiangolo.com/ |
| Angular | https://angular.dev |
| spaCy | https://spacy.io/ |
| Sentence Transformers | https://www.sbert.net/ |
