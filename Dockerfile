# Étape 1 : construire la documentation
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Créer un environnement virtuel et installer Sphinx + dependencies
RUN python -m venv venv \
    && . venv/bin/activate \
    && pip install --upgrade pip \
    && pip install sphinx sphinx-rtd-theme myst-parser \
    && if [ -f docs/en/requirements.txt ]; then pip install -r docs/en/requirements.txt; fi \
    && if [ -f docs/fr/requirements.txt ]; then pip install -r docs/fr/requirements.txt; fi


# Générer la doc EN (note: source est bien le dossier avec conf.py)
RUN . venv/bin/activate && sphinx-build -b html docs/en/source build/html/en

# Générer la doc FR
RUN . venv/bin/activate && sphinx-build -b html docs/fr/source build/html/fr

# Étape 2 : servir avec Nginx
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build/html /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]