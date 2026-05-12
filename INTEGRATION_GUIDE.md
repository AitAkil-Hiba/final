# 🚀 Guide d'Intégration Front-Back (Commerçant)

## 📋 Prérequis

- Backend Spring Boot lancé par l'équipe backend
- URL ngrok fournie par l'équipe backend
- Application Flutter prête

---

## 🔧 Étape 1 : Configuration de l'URL ngrok

1. **Recevoir l'URL ngrok** de l'équipe backend (ex: `https://abc123.ngrok.io`)

2. **Mettre à jour `lib/config/api_config.dart`** :
   ```dart
   // Remplacer cette ligne
   static const String baseUrl = 'https://URL_NGROK_ICI';
   
   // Par l'URL ngrok fournie
   static const String baseUrl = 'https://abc123.ngrok.io';
   ```

---

## 🧪 Étape 2 : Test de Connexion

### 2.1 Test de l'API de base
```dart
// Test simple pour vérifier la connexion
Future<void> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
      headers: await ApiService._getHeaders(includeAuth: false),
    );
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Erreur de connexion: $e');
  }
}
```

### 2.2 Test d'inscription commerçant
```dart
// Test d'inscription
Future<void> testMerchantRegistration() async {
  try {
    final result = await ApiService.registerMerchant(
      fullName: 'Test Commercant',
      email: 'test@example.com',
      password: 'password123',
      nomCommerce: 'Boulangerie Test',
      numeroRc: 'RC123456',
      siret: 'SIRET123456',
      cinPasseportUrl: 'https://example.com/cin.jpg',
      extraitRcUrl: 'https://example.com/rc.pdf',
    );
    print('Inscription réussie: $result');
  } catch (e) {
    print('Erreur inscription: $e');
  }
}
```

---

## 📱 Étape 3 : Test dans l'Application

### 3.1 Pages à tester

1. **Inscription Commerçant** (`merchant_signup_step4_page.dart`)
   - Remplir le formulaire d'inscription
   - Uploader CIN et extrait RC
   - Vérifier la réponse du backend

2. **Connexion** (`login_page.dart`)
   - Utiliser les identifiants créés
   - Vérifier le token JWT

3. **Mes Offres** (`mes_offres_page.dart`)
   - Charger les offres depuis l'API
   - Tester la création/suppression d'offres

4. **Accueil Commerçant** (`accueil_commercant.dart`)
   - Charger les réservations
   - Vérifier les données dynamiques

### 3.2 Points de surveillance

- **Console Flutter** : Vérifier les logs d'erreur
- **Réseau** : Surveiller les appels HTTP
- **SnackBar** : Messages d'erreur/succès

---

## 🔍 Étape 4 : Débogage

### 4.1 Erreurs communes

#### Erreur de connexion CORS
```
Solution: Demander à l'équipe backend d'ajouter ngrok aux CORS origins
```

#### Erreur 404/500
```
Solution: Vérifier que les endpoints correspondent à la documentation
```

#### Erreur d'authentification
```
Solution: Vérifier que le token JWT est bien stocké et envoyé
```

### 4.2 Outils de débogage

```dart
// Ajouter ces logs dans ApiService
static dynamic _handleResponse(http.Response response) {
  print('🔵 API Response Status: ${response.statusCode}');
  print('🔵 API Response Body: ${response.body}');
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isEmpty) {
      return {'message': 'Success'};
    }
    return json.decode(response.body);
  } else {
    final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {'message': 'Request failed'};
    print('🔴 API Error: ${errorBody['message']}');
    throw Exception(errorBody['message'] ?? 'API Error: ${response.statusCode}');
  }
}
```

---

## 📊 Étape 5 : Validation

### 5.1 Checklist d'intégration

- [ ] URL ngrok configurée dans `ApiConfig`
- [ ] Inscription commerçant fonctionne
- [ ] Connexion et token JWT fonctionnent
- [ ] Chargement des offres fonctionne
- [ ] Création/suppression d'offres fonctionne
- [ ] Messages d'erreur sont clairs
- [ ] Interface utilisateur reste responsive

### 5.2 Tests à effectuer

1. **Test complet d'inscription**
2. **Test de connexion/déconnexion**
3. **Test CRUD offres**
4. **Test avec réseau lent**
5. **Test avec erreurs backend**

---

## 🚨 Étape 6 : Dépannage

### Problèmes et solutions

| Problème | Solution |
|----------|----------|
| `Connection refused` | Vérifier que ngrok tourne et l'URL est correcte |
| `403 Forbidden` | Vérifier les CORS sur le backend |
| `401 Unauthorized` | Vérifier le token JWT |
| `Timeout` | Augmenter le timeout ou vérifier le réseau |

### Commandes utiles

```bash
# Pour tester l'API directement
curl -X GET "https://URL_NGROK/api/auth/me"

# Pour tester avec authentification
curl -X GET "https://URL_NGROK/api/offers" \
  -H "Authorization: Bearer VOTRE_TOKEN"
```

---

## ✅ Étape 7 : Validation finale

Une fois tous les tests passés :

1. **Nettoyer les logs de débogage**
2. **Retirer les URL ngrok hardcoded**
3. **Préparer pour la production**
4. **Documenter les éventuels ajustements**

---

## 📞 Support

En cas de problème :

1. **Vérifier les logs Flutter**
2. **Contacter l'équipe backend** avec les détails de l'erreur
3. **Partager les logs de la requête/réponse**

---

*Bonne intégration ! 🎉*
