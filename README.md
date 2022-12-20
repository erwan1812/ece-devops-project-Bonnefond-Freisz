# ece-devops-project-Bonnefond-Freisz

## 2. Appliquer le pipeline CI/CD

### 1. Pour la partie **continuous integration**, nous avons utilisés `GitHub Actions`

Nous avons commencés par créer un dossier `.github/workflows` à la racine de notre projet.
En repartant du lab sur CI/CD pipeline nous avons implémentés le fichier `github-actions.yml`. Nous l'implémentons seulement pour notre branche main.

```yml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

Ensuite, nous avons choisi un serveur `Ubuntu Linux` pour exécuter nos workflows lorsqu'ils sont déclenchés, et nous avons spécifié le `userapi` **Working directory**, ce qui permettra de récupérer les `packages` de ce fichier.

```yml
jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: userapi
```

Puis, on précise au server d'utiliser node.js ainsi que de `run` Redis ce qui nous permettra de lancer nos différents tests. Une fois que node.js et redis seront installés et configurés nous pourrons effectuer nos `test` :

```yml
steps:
      - uses: actions/checkout@v2
      - name: Start Redis
        uses: supercharge/redis-github-action@1.4.0
        with:
            redis-version: ${{ matrix.redis-version }}
      - name: Set up Node.js version
        uses: actions/setup-node@v1
        with:
          node-version: '16.x'

      - name: npm install, build, and test
        run: 
              npm ci
             npm run build --if-present
             npm test
      - name: Upload artifact for deployment job
        uses: actions/upload-artifact@v2
        with:
          name: node-app
          path: .
```

### 2. Pour la partie **Continuous Deployment**, nous avons utilisés `Azure`

On a commencé par créer un compte student qui nous permet d'avoir 100 crédits disponible sur le compte. Puis on a créer notre app en suivant le tutoriel du cours.
Notre applications est déployé sur : <https://project-devops-ece.azurewebsites.net/>

![image](image/2.png)

Ci-dessus notre journal de bord de nos workflows, depuis notre application réalisé sur Azure.

Une fois fait nous avons implémentés la partie deployment dans notre fichier `github-actions.yml`. Nous demandons dans cetter partie au serveur de vérifier si notre build(Continuous Integratio) fonctionne car il est nécessaire pour déclencher la partie deployment. (Build correspond à nos tests)

```yml
 deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'Production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v2
        with:
          name: node-app

      - name: 'Deploy to Azure Web App'
        id: deploy-to-webapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'project-devops-ece'
          slot-name: 'Production'
          publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE_7310E6DCC2614241A7CEB7B5BDE4A9F0 }}
          package: .
          appdir: userapi
```

Puis une fois que tout est bon. Il n'a plus qu`à le déployé sur azure.
Ci dessous un exemple d'un workflow réussi.

![image](image/1.png)

### Maintenant, dès que l'action d'un push ou d'un pull est déclenché un workflow se déclenche. Ci-dessous on peut voir un exemple que notre CI/CD pipeline se porte bien

![image](image/3.png)
