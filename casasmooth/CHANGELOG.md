# Changelog

## 2.0.102 - 2026-08-28

- **La borne de recharge se pilote comme n'importe quel appareil** : prix
  minimum, fenêtre horaire, présence, session. L'exécution écrit une consigne
  de courant au lieu de basculer un interrupteur. « Ne charge pas » devient un
  ralenti à 6 A — le minimum qu'un véhicule exige — et non un arrêt : sur une
  installation sans contacteur en amont, l'arrêt franc n'existe pas.

- **La borne apparaît aussi sur la carte de sa pièce**, plus seulement dans la
  vue Énergie et la vue Voiture.

- **Les tondeuses robots sont reconnues.** Home Assistant leur donne un domaine
  dédié que casasmooth ignorait : une tondeuse correctement rangée dans une
  pièce restait invisible partout. Elle a désormais sa section, ses commandes
  et sa bascule d'affichage.

- Retrait d'une bascule d'affichage « Home Energy » qui ne commandait rien et
  n'apparaissait dans aucun réglage.

## 2.0.101 - 2026-08-28

- **Facturation intégrée** : la box produit des pièces comptables et des
  QR-factures suisses, avec un nouveau tableau de bord « Facturation »
  (même accès que l'EMS, selon l'offre).

- **Export partenaire** : les index de compteurs — électricité, eau chaude,
  chaleur — sont servis au facturier au pas du jour, avec identifiants
  opaques et accès par le tunnel, derrière le jeton dédié.

- **Les capteurs du téléphone reviennent** via l'application compagnon
  casasmooth : batterie, activité et capteurs du véhicule (Android Auto)
  retrouvent leur catégorie et leurs vues.

- **Véhicule : l'application interroge d'abord la voiture (OBD)** avant
  d'estimer — les valeurs sûres priment sur les déductions.

- **Import KNX : le ré-import réconcilie** au lieu de dupliquer (ignorer /
  remplacer / créer, au choix), et un capteur de pluie se déclare par
  étiquette plutôt que d'être deviné par son nom.

- **Les alertes d'anomalie disent désormais quelle installation parle** —
  le nom de la box précède chaque SMS et notification.

- **Fin des consommateurs comptés deux fois** (Aqara, Eve, frient,
  myStrom) : une seule voie de mesure par appareil, et le **nettoyage de
  rétention passe en réel** après un mois de validation à blanc.

- **Le bouton qui bascule les prises d'une pièce existe aussi dans les
  pièces sans éclairage**, les tondeuses robots ont leur domaine, et la
  borne de recharge figure sur la carte de zone.

## 2.0.100 - 2026-08-27

- **Nouveau thème « Cogestim »** dans l'application mobile — identité claire
  aux couleurs de la régie (bordeaux, gris), à choisir dans Réglages → Thème.

- **Nouvel onglet « À propos »** (à activer dans Réglages → Panneaux) : le
  site de votre fournisseur s'ouvre dans l'application. Le site affiché se
  choisit dans les Réglages — casasmooth, Cogestim, Energie Thun — et un
  exploitant de parc pourra l'imposer à sa flotte.

- **Connexion de secours par e-mail** : le code à usage unique part par le
  canal transactionnel dédié — il n'est plus retenu par les protections
  anti-envoi-de-masse ni par un réglage d'expéditeur hérité.

- **La mise en service détecte un foyer à administrateur unique** : si un
  seul humain peut administrer la maison, la revue le signale — téléphone
  perdu = maison inadministrable — et propose le second compte et le canal
  e-mail de secours. Un foyer volontairement mono-admin peut l'accepter.

- **Les commandes internes déployées s'enregistraient parfois en retard**
  d'un redémarrage — corrigé, elles sont actives dès le déploiement.

- **Un capteur qui ne peut pas mesurer le dit** (« indisponible ») au lieu
  d'afficher une valeur inventée ou de disparaître.

- **Export des index de compteurs vers un facturier partenaire**, protégé
  par un jeton dédié — première brique de l'intégration décompte.

## 2.0.99 - 2026-08-27

- **Le bouton qui bascule toutes les prises d'une pièce fonctionne même si
  certaines prises n'ont pas encore d'état.** Une prise fraîchement
  intégrée (KNX notamment) reste « inconnue » quelques instants ; le bouton
  restait alors muet. Désormais : au moins une prise allumée → tout
  s'éteint ; sinon → tout s'allume.

- **Import KNX étendu** : thermostats (climate), lumières couleur RGB et
  blanc réglable, capteurs binaires enrichis, et création automatique des
  pièces du projet ETS. La suppression d'une entité importée nettoie
  proprement le store KNX.

- **Les règles d'énergie ne se re-déclenchent plus sur leur propre effet**
  (boucle refermée sur elle-même).

- **Supervision : un même défaut vu sur plusieurs installations est regroupé
  en un seul problème** au lieu d'une alerte par box.

## 2.0.98 - 2026-08-27

- **Un canal de secours pour la connexion à deux facteurs.** Si votre
  téléphone — et avec lui le code de connexion — est perdu ou en panne, un
  code à usage unique peut désormais vous être envoyé par e-mail. Au login,
  vous choisissez le canal ; l'e-mail s'active une fois pour toutes dans
  votre profil (Sécurité → modules d'authentification).

- **Les bornes de recharge deviennent pilotables en courant.** La consigne
  de courant d'une borne (Pico smart-me) peut être écrite par les règles
  d'énergie — la charge suit le surplus solaire ou le tarif, plus seulement
  marche/arrêt.

- **Les prises Swiss Domotique survivent aux mises à jour de firmware.**
  Le firmware Athom v2 renomme l'identité de la prise ; elle disparaissait
  alors des consommateurs. Les deux générations sont reconnues.

- **Import KNX : appariement automatique commande/état** et regroupement
  par appareil — un projet ETS importé donne des entités complètes, pas des
  moitiés d'interrupteurs.

- **La tuile « bon moment » dit d'où vient son signal** (surplus mesuré,
  immeuble, fenêtre solaire régionale), et la tuile gestionnaire de réseau
  date son offre — zéro échantillon ne s'affiche plus comme 0 %.

- **Nos e-mails font peau neuve** : envoi transactionnel dédié, lien de
  désabonnement en un clic, et fin de quelques doublons et boucles de
  notifications internes.

- **Récupérations web plus fiables** : nos requêtes sortantes s'identifient
  correctement — certains sites (protégés par Cloudflare) les refusaient.

- **Divers** : l'horloge d'indisponibilité du nettoyage d'appareils survit
  au redémarrage ; nouveau numéro de contact (077 267 42 37).

## 2.0.97 - 2026-08-26

- **Les bornes de recharge réapparaissent parmi les consommateurs.** Rangée
  comme borne, une station de recharge avait quitté la liste des appareils du
  graphique et sa consommation tombait dans le « non mesuré ». Elle y figure de
  nouveau, et elle est déduite du non mesuré en contrepartie — le total continue
  de se conserver.

- **La consommation d'une borne qui publie en kilowatts était comptée comme
  nulle** dans le calcul du « non mesuré ». Corrigé.

- **Le graphique de flux explique désormais pourquoi le solaire ne rejoint pas
  la maison** sur les installations dont les panneaux sont raccordés ailleurs :
  la phrase d'explication apparaît sous le graphique, et les libellés ont été
  raccourcis pour ne plus être coupés par la carte.

## 2.0.96 - 2026-08-26

- **Le graphique « Sources · Consommateurs » montre désormais la production
  solaire qui n'alimente pas le logement.** Sur une installation dont les
  panneaux sont raccordés ailleurs — derrière le compteur des communs, par
  exemple — la production apparaît comme source, reliée à sa seule destination
  réelle : l'injection au réseau. Elle ne rejoint jamais le domicile, ce qui
  fait voir d'un coup d'œil que les appareils de la maison sont alimentés par
  le réseau seul. Le bilan énergétique n'est pas modifié.

## 2.0.95 - 2026-08-26

- **Le graphique de flux montre désormais la production solaire qui n'alimente
  pas le logement.** Sur une installation dont les panneaux sont raccordés
  ailleurs — derrière le compteur des communs, par exemple — la production
  apparaît dans une bande séparée, reliée au réseau et détachée du reste du
  schéma. On voit ce que l'installation produit, et on comprend d'un coup d'œil
  que les appareils de la maison, eux, ne sont alimentés que par le réseau.
  Le bilan énergétique n'est pas modifié : cette production n'y entre pas.

## 2.0.94 - 2026-08-26

- **Les bornes de recharge s'affichent désormais sans voiture connectée.**
  Une installation équipée d'un chargeur mais dont le véhicule n'est pas
  intégré ne recevait aucun capteur de recharge — ni puissance, ni énergie,
  ni coût. Le chargeur seul suffit maintenant.

- **Immeubles : une puissance non mesurée s'affiche « indisponible » au lieu
  de 0 W.** Un capteur muet publiait un zéro, et l'occupant lisait « tu ne
  consommes rien » sur la foi d'une mesure que personne n'avait prise. Vrai
  pour la puissance d'un logement comme pour celle du bâtiment.

- **Le bâtiment retombe sur ses agrégats standard** quand la mesure dédiée
  n'est pas configurée, au lieu de publier une production et une consommation
  nulles qui se lisaient comme un immeuble éteint.

- **Bornes de recharge communes : la capacité d'absorption est apprise sur la
  puissance réellement observée**, au lieu de la valeur nominale déclarée —
  qui pouvait la surestimer du double.

- **L'écran de cohérence explique pourquoi un appareil n'est pas piloté**,
  au lieu de le laisser absent sans raison.

## 2.0.93 - 2026-08-25

- **La carte « Production PV hors logement » s'affichait sur toute
  installation**, même sans aucun panneau hors bilan déclaré — un capteur
  toujours présent en interne suffisait à la faire apparaître. Elle n'est
  désormais montrée que si un panneau hors logement a réellement été
  déclaré.

- **Les onduleurs solaires génériques (protocole SunSpec) sont reconnus
  automatiquement**, plus seulement les marques nommées une à une dans nos
  règles.

- **La carte « Prévision » se basait sur le mauvais capteur PV** et pouvait
  afficher une courbe incohérente avec la production réelle.

- **La borne de recharge Pico (smart-me) est maintenant reconnue comme
  borne**, avec sa puissance publiée dans la bonne unité (kW).

- **Traductions manquantes ou laissées en anglais/français** corrigées sur
  plusieurs écrans : sécurité, administration, monitoring, véhicule, air,
  santé, chauffage, aperçu, système, météo.

- **L'écran « Energy flow » de l'application mobile plantait** sur les
  installations utilisant ce module — corrigé.

- **Les appareils simulés (démonstration) sont mieux séparés du bilan mesuré
  réel**, et le mode « et si » peut désormais redimensionner batterie et PV,
  pas seulement simuler leur présence.

- **Le moteur de règles SGr est plus robuste** : budget de surplus et
  plafond de puissance appliqués correctement, règles mieux validées,
  comptabilités qui ne se mélangent plus entre logements, plus de vente de
  flexibilité fictive. Un capteur de cohérence tarifaire et des journaux
  longue durée permettent de suivre la qualité des décisions dans le temps.

- **Les notifications vocales qui ne jouaient que le carillon, sans la
  phrase, sont corrigées.**

- **Un décompte DIFEE pouvait facturer 0 CHF à un fluide réellement
  consommé, sans le moindre avertissement.** Corrigé.

## 2.0.92 - 2026-08-24

- **Une serrure Nuki dont le capteur de porte perdait sa lecture affichait
  « ouverte » en continu** — batterie faible, calibrage perdu, serrure
  retirée : tous les cas où le capteur n'a en réalité rien à dire étaient
  jusqu'ici confondus avec une porte réellement ouverte. Un cas constaté a
  duré huit jours sans que rien ne le distingue d'une vraie ouverture. Ces
  états affichent désormais « indisponible » ou « inconnu », jamais
  « ouverte » par défaut.

- **La carte des coûts énergie affichait des champs incohérents avec leur
  propre usage.** Six prix pouvaient valoir 1 centime sans que personne ne
  l'ait saisi, ce qui rendait impossible de distinguer un réglage oublié
  d'un réglage volontaire. Une valeur dix fois trop élevée pouvait rester en
  place sans déclencher d'alerte — corrigé ; toute installation vérifie
  désormais ses prix contre un plafond réaliste, pas seulement contre un
  plancher. L'indicateur de santé des sources tarifaires n'affichait plus
  clairement s'il fallait s'inquiéter. Le nom et le site du fournisseur —
  qui ne servent qu'à l'affichage — sont désormais rangés à part des
  réglages qui déterminent réellement votre facture, et ne sont demandés
  qu'aux installations qui les affichent réellement.

- **Le calcul d'optimisation peut désormais distinguer deux régimes légaux
  d'injection au réseau.** Un foyer n'ayant signé aucun contrat spécifique
  est payé selon un tarif de référence fixé chaque trimestre, pas selon le
  cours de l'heure : le pilotage peut désormais refléter cette réalité
  plutôt que de rechercher, heure par heure, un gain qui ne lui est pas
  applicable.

## 2.0.91 - 2026-08-24

- **Votre facture repose désormais sur le tarif officiel de votre commune.**
  Un ménage suisse consommant moins de 100 MWh par an est lié à
  l'approvisionnement de base de son gestionnaire de réseau : le tarif publié
  par celui-ci *est* son prix. Il n'entrait pourtant dans aucun de nos calculs
  de coût, qui se rabattaient sur une valeur saisie à la main — quand elle
  l'avait été. Le tableau de bord et l'application mobile pouvaient ainsi
  afficher deux prix différents pour la même électricité. Il n'y a plus qu'un
  seul prix, et il indique sur quoi il repose.

- **Le tarif officiel est maintenant récupéré aussi avec l'abonnement énergie
  standard.** Il y était réservé à l'offre avancée, alors que c'est le prix par
  défaut légal du foyer et non une fonction supplémentaire.

- **La rétribution minimale légale d'injection est prise en compte.** Depuis
  janvier 2026, une installation de moins de 30 kWc a droit à au moins
  6 ct./kWh pour l'électricité qu'elle injecte. Un décompte trimestriel —
  la maille à laquelle la loi et votre gestionnaire de réseau raisonnent —
  indique le montant garanti et vous dit quand ce minimum s'applique. Le prix
  instantané, lui, continue d'afficher la réalité du marché, y compris
  négative : c'est ce qui vous dit de ne pas exporter à cet instant.

- **Les électroménagers Home Connect sont reconnus par gamme.** Seuls trois
  modèles précis l'étaient ; tout autre lave-vaisselle Bosch ou four Siemens
  restait invisible. Lave-vaisselle, sèche-linge, hottes et — c'est nouveau —
  lave-linge sont désormais reconnus pour Bosch, Siemens, Neff, Gaggenau et
  Constructa.

- **Le CO₂ de votre réseau est enfin lu sur les installations non
  francophones.** Le nom du capteur Electricity Maps dépend de la langue de
  votre système : casasmooth n'en connaissait que deux et retombait
  silencieusement sur la moyenne suisse — tout en continuant de vous
  recommander de connecter ce que vous aviez déjà connecté.

- **Le tableau de bord casasmooth se remet en place s'il a été changé.** La
  vérification était sautée pendant 24 heures après chaque passage, si bien
  qu'un tableau par défaut modifié ne revenait pas. L'onglet « Overview » de
  Home Assistant est masqué, et un échec est désormais signalé.

- **Le numéro de commune (BFS) est un champ texte.** Il s'affichait avec des
  flèches et une virgule, comme une quantité. Une valeur déjà saisie est
  reprise automatiquement.

- **Rattrapage : la version 2.0.90 contenait aussi la traduction complète de
  la vue Énergie** — dix-huit catégories de coûts, le bloc tarifaire et une
  soixantaine de libellés s'affichaient en français ou en anglais quelle que
  soit la langue choisie. Ces notes ne le mentionnaient pas.

## 2.0.90 - 2026-08-23

- **La prévision solaire régionale ne pouvait pas s'exécuter.** Le capteur qui
  donne la forme du jour — et la fenêtre « bon moment pour lancer un gros
  consommateur » qui en dépend — restait vide sur toutes les installations. Il
  s'appuyait sur un chemin interne qui n'existe que sur une machine de
  développement ; il passe désormais par le même canal que tous les autres
  capteurs de ce type. La prévision, la fenêtre solaire et l'échelle des
  signaux fonctionnent enfin sur une installation normale.

- **La recherche web technique de l'assistant était muette.** Le petit
  programme qu'elle appelle n'était en réalité livré sur aucune installation :
  il était transformé en fichier compilé avant d'être copié, et la copie ne
  trouvait donc rien. Il est de nouveau livré, et son absence éventuelle est
  désormais signalée dans le journal au lieu de passer inaperçue.

## 2.0.89 - 2026-08-23

- **Le diagramme des flux d'énergie se referme enfin** — toute la production
  aboutissait au logement, si bien qu'une installation produisant 8 kW pour
  700 W consommés affichait un flux entrant sans destination. Le réseau et la
  batterie ne sont pas des consommateurs : ce sont les deux destinations du
  surplus, et elles figurent désormais comme telles. Ce qui entre égale ce qui
  sort.

## 2.0.88 - 2026-08-23

- **Les liens envoyés par courriel pointaient vers l'adresse locale de la box** —
  le module d'invitation recalculait l'adresse publique de son côté, avec une
  copie du code qui n'avait pas reçu une correction faite ailleurs. Le
  destinataire, qui n'est par définition pas sur le réseau local, recevait un
  lien mort. Il n'y a plus qu'une seule façon de résoudre cette adresse.
- **L'adresse publique résolue est désormais consultable** — elle se choisissait
  en silence, et son échec ne se voyait que bien plus tard, dans un QR code
  affiché au mur ou un courriel qui ne s'ouvre pas.

## 2.0.87 - 2026-08-23

- **Les liens de l'index des consoles fonctionnent depuis n'importe où** — ils
  pointaient vers l'adresse locale d'usine de la box, un nom qui ne se résout ni
  à distance, ni depuis un téléphone, ni sur une installation qui porte une autre
  adresse. Le lien s'affichait normalement ; il était simplement mort. Il suit
  désormais l'adresse par laquelle vous consultez le tableau de bord.

## 2.0.86 - 2026-08-23

- **Le flux d'énergie montre enfin un flux** — une flèche indique qui alimente
  qui, là où trois cadres côte à côte laissaient deviner.
- **La production hors logement y apparaît** — l'encadré affichait un tiret
  pendant que les panneaux produisaient, faute de lire autre chose qu'une
  grandeur du bilan. Elle est désormais montrée sous son propre nom.
- **Les équipements absents ne prennent plus de place** — un logement sans
  batterie n'affiche plus une case de batterie vide.
- **Les liens de la box pointent enfin sur la box** — l'index des consoles, les
  QR collés au mur et les liens des e-mails renvoyaient tous vers
  `homeassistant.local`, une adresse qui ne répond que depuis le réseau local.
  Ils portent désormais l'adresse publique de l'installation.
- **Chaque appareil porte enfin son nom dans les règles d'énergie** — un
  lave-vaisselle rangé dans la cuisine s'annonçait « Cuisine Chauffage », et la
  fiche qui s'ouvrait au clic montrait tout autre chose. Le libellé par zone
  était réservé aux appareils de chauffage ; il s'était étendu, sans le dire, à
  tout appareil compté par son index.

## 2.0.85 - 2026-08-23

- **La carte des coûts par usage** — où part l'argent, classé du poste le plus
  cher au moins cher, en francs plutôt qu'en kilowattheures, avec la dépense du
  mois projetée « à ce rythme ». La projection n'apparaît qu'à partir du
  troisième jour : un seul jour atypique la rendrait trompeuse.
- **La veille permanente y figure en évidence** — ce que le logement consomme
  quand personne n'y touche, et ce que cela représente sur une année. C'est
  souvent le poste le plus facile à réduire, et celui que personne ne regarde.

## 2.0.84 - 2026-08-22

Le coût par usage — parce qu'un kilowattheure ne parle à personne, et trois
cents francs par an, si. *(Pack Énergie avancé.)*

- **Coût par usage, journalier et mensuel** — la dépense se répartit entre
  usages au prorata de leur consommation, avec le prix réellement payé sur la
  période. La somme des usages égale donc toujours la dépense réelle : le
  tableau se réconcilie avec la facture, toujours.
- **Veille permanente** — ce que le logement consomme quand personne n'y touche,
  mesuré comme le minimum sur 24 heures, et son coût annualisé. Sur le pilote
  Energie Thun : 140 W en continu, soit environ 330 francs par an, maison vide.
- **Coût au prix moyen** — la même consommation facturée au prix moyen de la
  période. L'écart avec la dépense réelle isole le seul bénéfice du décalage des
  usages : ni la météo, ni le contrat, ni le niveau de consommation n'y entrent.
  Un écart défavorable s'affiche comme un autre.

## 2.0.83 - 2026-08-22

- **Correctif : le conseil « bon moment » ignorait la production hors logement.**
  Le seuil se compare en watts, mais la valeur lue était celle du fournisseur —
  souvent en kilowatts. Une production de 3 890 W se lisait donc « 3,89 », loin
  sous le seuil, et le conseil restait muet alors que les panneaux tournaient.
- **La date suit enfin la langue de l'interface** — elle s'affichait en anglais
  sur un tableau de bord allemand, et au format américain. Jour traduit, date au
  format suisse.

## 2.0.82 - 2026-08-22

- **« C'est le bon moment » sur l'accueil** — une phrase avant les chiffres, pour
  qui ne veut pas lire des watts : faut-il lancer la machine maintenant, et
  pourquoi. Le conseil croise **deux** raisons indépendantes — une source
  disponible, et un prix plus bas que dans l'heure qui suit — parce que sur un
  site dont toute la production part au réseau, seul le moment d'achat fait la
  différence. Quand rien n'est mesurable, la carte le dit au lieu de répondre
  « non ».
- **La production hors logement apparaît dans l'application mobile** — l'écran
  affichait « Panneaux : — kW » pendant que les panneaux produisaient, faute de
  lire autre chose qu'un capteur de bilan. Elle est désormais nommée et donnée
  pour ce qu'elle est : produite, non comptée ici. Même correction sur la vue
  Energie Thun et sur la carte énergie de l'accueil.

## 2.0.81 - 2026-08-22

Les sources qu'on possède sans en être alimenté deviennent une notion complète :
hors du bilan, mais visibles et utiles au pilotage.

- **Batterie hors logement** — un stockage partagé ou distant peut désormais se
  déclarer, avec ses propres agrégats de puissance et de charge. Ils restent
  strictement séparés de ceux du logement : la charge moyenne locale commande le
  palier de prix, les seuils de chaque appareil et le pilotage de tout un
  immeuble, elle ne doit jamais bouger parce qu'une batterie voisine s'est
  déclarée.
- **Les sources hors bilan apparaissent dans la carte Sources** — c'est là que
  l'habitant vient voir ce qui l'alimente, et ces sources vont piloter ses
  appareils. Une machine qui démarre à cause d'une production invisible rend le
  comportement de la maison inexplicable. Le libellé dit clairement qu'elles ne
  sont pas comptées.
- **« Bon moment pour consommer » fonctionne enfin sur ces sites** — un logement
  dont toute la production est hors bilan n'avait aucune source à interroger : la
  tuile restait grise en permanence.
- **La production hors bilan ne fausse plus la planification** — sa prévision
  alimentait l'optimiseur, qui différait des consommations en attendant un soleil
  dont le bénéfice va ailleurs.

## 2.0.80 - 2026-08-22

- **Correctif : les totaux journaliers d'énergie réseau avaient disparu.** En
  adossant ces totaux au compteur mesuré (2.0.79), leur nom suivait celui de leur
  nouvelle source — les graphiques qui les citaient pointaient donc dans le vide.
  Les noms sont rétablis et ne dépendent plus de la provenance : seule la source
  change, jamais l'identité de la série.
- **Les appareils qui ne publient qu'un index cumulé sont enfin comptés** —
  l'électroménager communicant ne publie pas de puissance instantanée ; il était
  écarté du décompte par usage et sa consommation tombait dans le « non mesuré ».
  Un appareil n'est écarté que s'il est déjà compté par ailleurs, ce qui reste le
  seul cas de double comptage.
- **Index d'énergie V-ZUG reconnu** — les lave-vaisselle, lave-linge et
  sèche-linge de la marque entrent désormais dans la ventilation par usage.

## 2.0.79 - 2026-08-22

- **La version affichée dans l'application est celle qui tourne vraiment** —
  elle était gravée dans l'application au moment de sa compilation, et pouvait
  donc annoncer une version périmée : soit parce que l'application avait été
  compilée avant la montée de version, soit — le cas courant — parce que le
  navigateur en servait une copie mise en cache. L'écran Réglages interroge
  désormais la box, qui sait toujours ce qu'elle exécute.

## 2.0.78 - 2026-08-22

- **Thème clair : les cartes redeviennent des objets** — posées blanches sur un
  fond gris clair et sans contour, elles flottaient sans limite lisible. Elles
  reçoivent un liseré, le fond de page descend d'un ton, et les textes
  secondaires comme les intitulés de section sont densifiés : sur fond blanc,
  les gris calibrés pour un thème sombre passent sous le seuil de lisibilité.

## 2.0.77 - 2026-08-22

- **L'énergie facturable vient du compteur, plus d'un calcul** — quand le
  compteur du logement publie ses index cumulés, les totaux journaliers,
  mensuels et annuels s'y adossent directement. Jusqu'ici ils reposaient sur une
  reconstitution à partir de la puissance, échantillonnée toutes les cinq
  minutes : acceptable pour un tableau de bord, inadapté à un décompte. Les
  installations sans compteur communicant conservent ce calcul.
- ⚠️ **Après la bascule, remettre les compteurs de période à zéro** (bouton
  « Réinitialiser les capteurs d'énergie ») : l'index d'un compteur n'a aucun
  rapport avec le cumul précédent, et l'écart serait sinon enregistré comme une
  consommation.

## 2.0.76 - 2026-08-22

- **Vue EMS enfin lisible en thème clair** — ses cartes se dessinaient avec un
  voile sombre très léger, une recette pensée pour un fond noir : posée sur une
  page presque blanche, elle ne détachait plus rien. Les cartes deviennent
  blanches sur une page grise, avec un liseré franc, et les textes secondaires
  sont densifiés.
- **Couleurs de la prévision et des indicateurs adaptées au thème clair** — les
  tons pastel choisis pour un fond sombre viraient au lavis sur blanc.

## 2.0.75 - 2026-08-22

Métrologie : l'énergie mesurée d'un compteur devient publiable, et la prévision
solaire cesse d'exiger une connexion.

- **Facteur d'échelle par point de mesure** (`scale:`) — certains compteurs
  publient leur énergie cumulée dans une unité que rien ne nomme. Le facteur se
  pose dans le manifeste de l'appareil, sans toucher au code ni à la définition
  du protocole. Un facteur absurde est refusé et vaut 1 : un compteur à zéro ne
  se distingue pas, dans l'historique, d'une maison à l'arrêt.
- **Compteurs cumulés déclarés `total_increasing`** — sans cette déclaration,
  Home Assistant ne construit aucune statistique long terme : le relevé
  s'affiche mais reste inexploitable pour un décompte.
- **Énergie du whatwatt Go publiée** — son échelle a été mesurée sur le terrain
  (relevés chronométrés comparés à la puissance instantanée) : une unité vaut
  0,1 Wh. Le soutirage et l'injection cumulés deviennent des grandeurs mesurées,
  là où seule une intégration de la puissance existait.
- **Prévision solaire d'un onduleur sans lien local** — la puissance crête est
  une plaque signalétique, pas une connexion. Un onduleur lisible uniquement par
  le cloud voyait sa prévision silencieusement ignorée.
- **Détection V-ZUG élargie** — les modèles dépourvus du module `hh` (AdoraDish
  V2000) étaient invisibles au scanner alors que l'intégration sait s'en passer.
  Toujours sans réveiller l'appareil.

## 2.0.74 - 2026-08-22

- **Les capteurs dérivés portent enfin leur nom** — consommation du logement,
  PV hors bilan, consommation non mesurée : le correctif de nom humain de
  2.0.73 n'avait couvert qu'un des deux constructeurs de capteurs, laissant en
  identifiant brut précisément les plus visibles du tableau de bord.

## 2.0.73 - 2026-08-22

Ce que le client voit : un thème clair lisible, des capteurs qui portent un nom,
et des entités mortes qui disparaissent enfin.

### Interface

- **Thème clair contrasté** — fond de page nettement gris pour que les cartes
  blanches ressortent, textes densifiés, liserés de tuiles visibles.
- **Vue EMS illisible en clair, corrigée** : le mode clair de l'EMS n'était lu
  qu'au chargement du module, et un ancien appui sur ☀️/🌙 l'épinglait
  définitivement — l'app en clair affichait donc la vue avec ses couleurs
  sombres, texte quasi blanc sur fond clair. Choisir un thème réaligne
  désormais l'EMS immédiatement.
- **Tuile « bon moment pour consommer »** : n'apparaît plus que si le logement
  a du PV. Sans PV maison (injection directe au réseau), le capteur répond
  honnêtement « je ne sais pas » — la tuile restait grise à demeure.

### Entités

- **Noms humains sur les capteurs générés** — le libellé passe par
  `customize:`, seul chemin qui tienne (Home Assistant recalcule
  `friendly_name` depuis le nom technique et écrasait la valeur). Les 28
  capteurs `cs_power_*` s'affichaient en identifiant brut, jusque dans le
  diagramme de flux.
- **Nettoyage des orphelines étendu aux entités `template:`** — capteurs,
  interrupteurs et nombres retirés du code restaient inscrits au registre, donc
  toujours posés sur les dashboards en « indisponible ». Le nettoyage ne touche
  que les entités de la plateforme `template`, ce qui met hors de portée les
  compteurs, intégrateurs, `command_line` et les capteurs MQTT d'un logement.

### Support

- **Le jeton d'accès distant remonte tout de suite** : le coller dans l'écran
  d'administration ne déclenchait rien jusqu'au prochain démarrage ou à
  06:15/18:15 — le cloud gardait l'ancien jeton, révoqué entre-temps, et tout
  accès de support échouait.

## 2.0.72 - 2026-08-21

Une box de production ne porte plus d'appareils synthétiques.

- **Banc d'essai SGr désormais opt-in** (`sgr_sim_enabled`, défaut off, même
  idiome que les intégrations vendorées). Depuis le 06.07.2026, **toute** box
  abonnée `enhanced_energy` générait 19 entités simulées — PAC, chauffe-eau,
  chargeur VE, batterie — au milieu des vrais appareils. Inertes hors mode
  `simulation`, mais sur un pilote destiné au décompte (vZEV/LEG) c'est le
  mélange « synthétique × mesuré » que le modèle énergétique interdit.
  Constaté sur EnergieThun. Le banc reste disponible là où il sert (jumeau,
  banc, développement) en posant le drapeau.
- ⚠️ Conséquence assumée : sans le drapeau, le mode `cs_sgr_mode = simulation`
  n'a plus de cible — c'est un outil de banc, pas une fonction client.

## 2.0.71 - 2026-08-21

Couche coût énergie réelle, thème clair lisible, et la topologie immeuble
T1/T2 (travaux de plusieurs sessions consolidés dans cette version).

### Énergie & coûts

- **La couche coût s'appuie enfin sur un prix d'achat RÉSOLU** (détail, jamais
  gros) : nouveau `sensor.cs_grid_price_resolved_chf_kwh`, tous les templates de
  coût repointés. La carte des coûts et le coût du jour affichent des montants
  réels au lieu du plancher `0.01`.
- **Un tarif dynamique de DÉTAIL sain est reconnu facturable** (`import_mode`
  `dynamic`), au lieu de retomber en `spot_only` — la tuile de coût mobile
  cesse d'afficher « — » quand la box calcule pourtant le bon prix.
- **Carte des coûts** redressée : plus d'entité fantôme ni de tuile vide,
  sections repliables cohérentes, injection qui dit son forfait, retrait des
  cartes HA natives au profit des cartes casasmooth.
- **Topologie immeuble T1/T2** : « déclaré vs observé », canal montant des
  moyennes de zone T1→T2, plancher/​fenêtre solaire régional pour une box sans
  mesure, garde de fraîcheur.

### Domotique & réseau

- **Identifiants MQTT par box** (+ ACL en écriture), avec repli sur le compte
  partagé.
- **PV hors bilan** exploité comme **signal de pilotage** SGr (fenêtre solaire
  lissée), sans jamais entrer dans le bilan du logement.
- **DIFEE** : le ledger ne fabrique plus de zéro (compteur mort, panne, reset).

### Interface

- **Thème clair lisible** : fond de page soutenu pour que les cartes blanches
  ressortent, tuiles en puces douces (allumées ambrées), textes assagis.

## 2.0.70 - 2026-08-19

Renommage self-service du slug de tunnel depuis le dashboard Admin.

- **Champ slug éditable** (carte Admin) : l'owner tape une URL courte
  (`ent` → `ent.casasmooth.net`) et presse un bouton. Le box relaie au cloud,
  qui impose le **format** et l'**unicité fleet-wide** (409 si déjà pris) ; le
  verdict s'affiche en notification. La nouvelle URL route au prochain
  redémarrage de l'add-on (frpc re-render au boot).
- **Endpoint durci** (analyse adverse) : `/api/internal/tunnel/rename_slug`
  exige le **guid comme secret partagé** (`_validate_internal_guid`), pas
  l'origine réseau seule — `:28100` binde `0.0.0.0` et le LAN de la box peut
  l'atteindre. Course cache-token au 1er boot corrigée (`reset_cache` +
  relecture) ; slug échappé via `| tojson` ; URL cloud via `cloud_api_base()`.

## 2.0.69 - 2026-08-18

Nouvelles intégrations d'appareils et outil de mise en service, plus deux
passes d'analyse adverse sur tout le code de la session.

### Intégrations d'appareils

- **V-ZUG (électroménager) vendoré** (`vendor/vzug`, drapeau `vzug_enabled`,
  toggle Admin) — gamme AdoraDish/Wash/Dry, API locale sans auth, découverte
  DHCP native ; règles `cs_rules.csv` par `platform=vzug` + modèle.
- **whatwatt Go en REST** — EID privé `whatwatt_go_local_rest.xml` lisant
  `GET /api/v1/report`, sans activer Modbus par appareil. Marche sur toute unité
  licenciée. Résolu depuis l'image (fallback `app/data` embarqué dans
  `SGrService._resolve_eid`).
- **PV hors bilan logement** — nouvelle catégorie `power_offsite_pv_sensors` :
  production possédée mais qui n'alimente pas le logement (injection réseau
  directe). Affichée, **exclue** du bilan et de l'auto-suffisance. Configurable
  par label humain `csx_power_offsite_pv_sensors` (le classement par règle seul
  n'ouvre pas la dérivation réseau).

### Mise en service

- **Scanner LAN généraliste** (`app/services/net_fingerprints.py`, endpoints
  `POST /api/sgr/discover/fingerprint`) : identifie les appareils que
  l'autodécouverte HA rate (whatwatt, V-ZUG, Shelly, Tasmota, smart-me).
  Validé sur un vrai LAN. N'intègre rien — c'est un outil qui indique quel
  chemin d'intégration suivre. Découverte SGr désormais joignable par le tunnel.

### Corrections (analyse adverse ×2)

- `_apply_label_overrides` lisait `category` au lieu de `cs_category` : un
  correctif humain `csx_` n'écartait jamais l'entité de sa catégorie de règle
  (bug préexistant, tout `csx_` concerné). Corrigé + test au niveau registre.
- Divers durcissements du scanner (pas de redirection suivie, lecture bornée,
  deadline effective, sonde V-ZUG non perturbante) et de l'EID whatwatt
  (enveloppe `report.`, échelle en JSONata, puissance réseau signée).

## 2.0.68 - 2026-08-18

Release corrective : le montage d'un pilote physique a mis au jour un
bug qui rendait les intégrations vendorées ininstallables sur toute box released.

### Intégrations vendorées (smart-me / bermuda / loxone / nuki_ng)

- **`run.sh` synchronise enfin `vendor/` vers `/config/casasmooth`.** L'image
  embarquait bien `vendor/` (depuis 2.0.66), mais le script de démarrage ne le
  copiait pas du dossier image vers le dossier données, où `cs_update` le
  cherche. Résultat : `nuki_ng` (inconditionnel) et les intégrations à drapeau
  (smart-me/bermuda/loxone) n'étaient jamais installées — l'interrupteur
  « activer l'intégration » du tableau de bord était un no-op silencieux. Une
  ligne dans la boucle de sync. Le correctif `4e3e87b6f` (embarquer `vendor/`
  dans l'image) n'avait traité que la moitié du problème.
- Le scope du cache de build est remis à sa valeur d'origine : le suffixe `-g2`
  ajouté la veille reposait sur un diagnostic erroné (le bug était dans `run.sh`,
  pas dans le cache Docker — les images 2.0.67 contenaient `vendor/` au complet).

## 2.0.67 - 2026-08-18

Release de correctifs, motivée par le montage d'un pilote physique :
chaque défaut ci-dessous a été constaté sur du matériel réel (banc isolé, jumeau
`.61`, box de développement `.149`), pas en théorie.

### Sécurité

- **`require_auth()` ne fait plus confiance à des signaux forgeables à travers
  le tunnel.** Un en-tête `X-Casasmooth-Context: lovelace` (ou un referer
  `/lovelace/`, ou `/local/mobile/`) faisait passer une requête sans jeton pour
  une requête de confiance. Neuf routers en dépendaient ; ils délèguent
  désormais à `compute_transport_trust()`, la même classification que le
  middleware HTTP et les WebSockets, qui neutralise le contournement dès que le
  `Host` révèle le tunnel. Portée réelle : LAN uniquement (le relais tunnel
  avait déjà deux serrures depuis le 13.08), mais la duplication d'heuristiques
  d'auth est fermée à la racine.

### Accès distant

- **Le frontend HA cesse de renvoyer 400 « untrusted proxy » à travers le
  tunnel sur une box neuve.** Le correctif de proxy inverse se croyait en échec
  et se désactivait après trois tentatives : il comparait `trusted_proxies`
  comme des chaînes alors que HA les canonise en préfixes (`127.0.0.1` →
  `127.0.0.1/32`). Toute box née d'un gold restait sans accès distant, en
  silence.

### Énergie

- **Le tarif d'import peut enfin être réglé sur « aucun ».** L'option n'existait
  que côté injection ; côté import, impossible d'arrêter de poller un endpoint
  par-client (Swisspower) — deux box sur le même code se 429 mutuellement et
  dégradent le vrai client. Choisir « aucun » coupe le fetch et efface la courbe
  périmée (une courbe gelée est pire qu'aucune, elle a l'air vivante).
- **`scipy` déclaré comme dépendance** : sans lui l'optimiseur SGr retombait en
  silence sur une heuristique gloutonne qui ne modélise pas les accumulateurs
  thermiques ni la bande de confort.

### Tableau de bord

- **Plus de « Entity not found » dans la météo dès que la maison est renommée.**
  `weather.forecast_home` était codé en dur ; Met.no nomme l'entité d'après le
  lieu, donc une box « Maison » a `weather.forecast_maison`. L'entité est
  désormais résolue dynamiquement (cinq cartes, trois vues).
- **Le dernier lien de l'onboarding pointe sur le tableau de bord casasmooth**
  (`/cs-home/home`) et non plus sur `/lovelace`, vide sur une box casasmooth.

### Assainissement (gold / clones)

- **`core.config` neutralisé à la capture** : position GPS, nom du lieu et URLs
  d'accès de la machine source ne partent plus dans chaque carte livrée. Une box
  née d'un gold naissait aux coordonnées de l'intégrateur et calculait sa
  prévision solaire pour le mauvais endroit, en silence. Les réglages produit
  (unités, fuseau, devise, pays, langue) sont conservés.

## 2.0.66 - 2026-08-17

### Intégrations avancées activables depuis le tableau de bord

- **Nouveaux interrupteurs dans Administration → « Consoles »** pour activer ou
  désactiver **Loxone, Bermuda et smart-me** sans passer par la ligne de
  commande. Activer une intégration l'installe, **redémarre la box** (~1–2 min),
  et fait apparaître son raccourci (p. ex. « Connecter Loxone ») juste en
  dessous. Garde-fou intégré contre la boucle de redémarrage au démarrage.
- **La vue d'onboarding Loxone (`?view=loxone`) fonctionne enfin** : le bundle
  mobile n'avait jamais été reconstruit avec elle (2.0.65 en livrait la source
  sans le build). Bundle reconstruit ; la vue est listée dans la carte
  « Consoles » dès que Loxone est activé.

### Carte « Consoles » réparée

- La section « Consoles & outils » était **inatteignable** (aucune tuile de
  visibilité dans le panneau d'affichage) — corrigé.
- Retrait des vues « Sécurité » et « Plan 3D » du registre : c'étaient des liens
  morts.

### Énergie

- Carte des coûts réorganisée en **6 sections repliables**, avec une sentinelle
  de cohérence en tête (5 langues) et l'indication du forfait d'injection.
- Les sources du modèle énergétique (compteur, PV, batterie, consommation
  publiée) se rendent enfin comme **tuiles** dans le panneau de zone.
- Section Énergie enfin visible sur une **box neuve** (booléen de section qui
  naissait à off — corrigé).
- Capteurs `cs_*` qui naissaient sans nom lisible, et forfait d'injection pris à
  tort pour une alerte — corrigés.

### Assainissement (gold / clones)

- `restore_state` filtré à la généralisation (c'était un canal de fuite
  d'identité entre clones).
- La Pico entre dans le modèle ; les clones **ne naissent plus « malades »**.

### SGr / optimiseur

- Une **fenêtre active** est lue comme contrainte dure dès le premier cycle
  (plus de `manual_override` transitoire d'une heure).
- L'adoption émet les points d'écriture du modèle 123.

### Administration

- Le nettoyage purge aussi les **zones vides** (après les appareils) ; message
  de notification corrigé (« 1 zone vide supprimée »).
- Vue vocale autonome rebasée sur le pipeline unique `useVoiceSession`.

## 2.0.65 - 2026-08-16

### Fixed — the energy model now measures the house, not the inverter's guess

- **House consumption can now be derived at the grid connection point.** On
  installations whose inverter publishes no consumption (a meter-less Huawei
  SUN2000 is the pilot case), the house total is derived from the energy
  balance: `PV + import − export − battery`, clamped at zero. Previously such
  installations simply had **no** consumption figure at all.
- **A Modbus meter (whatwatt Go and any Chemin-2 device) becomes real HA
  entities — without SGr.** Declared metering points are read every minute and
  published as sensors, deliberately not gated by `enhanced_energy`: a meter is
  measurement infrastructure, not an optimisation feature. The meter's active
  power is routed to the grid category, closing the loop for the derivation
  above. (Also fixed on the way: the whatwatt EID counts in Wh, not kWh.)
- **The SGr optimizer believed the house consumed zero.** It read two entities
  that have never existed, so PV surplus was computed as `pv − 0` — measured
  1983 W instead of 1097 W on the reference box. It now resolves the real
  aggregate names.
- **Sensors reporting kilowatts were counted a thousand times too low.** Unit
  rules match `kW` as well as `W` (by design — inverters differ), but the power
  aggregates summed raw values without unit conversion, so a 3.5 kW producer
  contributed 3.5 "watts". Aggregation now converts per-entity from the unit
  the registry declares, and a non-power unit that slips into a power category
  is excluded and logged instead of corrupting the total.
- **Schedules and sessions could be dead letters.** When a consumer's
  `consumer_id` could not be resolved directly it is now recovered through the
  switch-entity helpers.

### Fixed — a boiler can no longer be optimised into staying cold

- A **sanitary floor** guarantees minimum hot-water comfort regardless of what
  the optimiser decides, and suspends itself while the household is away.
- The energy schedule is now a **real window**: SGr is free to act outside it
  and no longer abandons the schedule when the Auto toggle is off.
- Unified precedence: the toggle says whether a device is controlled at all,
  `cs_energy` decides, SGr fills the gaps. Matter overrides are temporary
  again, a manual grace is persisted across restarts, and a watchdog alerts
  when a consumer keeps a schedule that nothing applies anymore.

### Fixed — fresh boxes on HA 2026.8 no longer greet the tunnel with a 400

- HA 2026.8 ignores the YAML `http:` block after its one-shot migration, so a
  freshly onboarded box rejected the tunnel as an untrusted proxy. The
  `trusted_proxies` configuration is now applied through the WebSocket store,
  with a version guard that skips boxes still below 2026.8.

### Fixed — rules engine: dead lookups, dead rules, and a caller with a name

- Several features silently targeted categories that do not exist: AI shutter
  actions resolved **no entities** in any area, areas with only reclassified
  bulbs got no scene automations, frigate camera switches were filed under
  lighting, and one AI-text rule sat unreachable behind the MQTT catch-all.
  All fixed; two dead duplicate rules removed (452 → 450).
- The unknown-category warning now names **file, line and function of the
  caller**, turning a day of stack-trace hunting into reading one log line.
- The MQTT fallback category for a manual cover no longer resurrects the
  retired `covers` name — those entities land in `shutters` and stay visible.
- The companion sidecar rules follow the app's strategy change: the two
  surviving entities (`phone_last_seen`, `phone_app_health`) are categorised
  again instead of falling into the catch-all.

### Added — integrations

- **Nuki**: `nuki_ng` is vendored (its callback speaks plain HTTP toward the
  Bridge even when `internal_url` is HTTPS, and it no longer fights for the
  bridge's callback slot 0). Existing core-`nuki` installations are adopted
  **automatically at startup** — entities are regenerated and re-assigned to
  their areas, no manual step.
- **Loxone**: onboarding path for the Miniserver — cs-api endpoints
  (`/api/loxone/connect|status`), SSDP/UDP discovery pre-filling the IP, and a
  mobile onboarding view (`?view=loxone`; view still untested on-device).
- **`vendor/` is actually inside the add-on image now.** Without this, every
  `<name>_enabled` flag (smartme, bermuda, loxone, nuki_ng…) was a silent
  no-op on production boxes: `cs update` copied nothing and said nothing.
- Administration dashboard: a registry of mobile views with a
  "Consoles & tools" card.

### Added — twin & tooling (does not ship on boxes, but proves what does)

- The pilot-site digital twin (VM 331) runs the full chain end to end: real
  FusionSolar production (first production validation of the Kiosk client)
  drives the simulated grid meter, so `house = PV + import − export` is now
  verified against a curve a real roof produced.
- The rules CSV and the cloud rules-service are kept honest by a read-only
  drift probe (repo ↔ service, categories, rules **and order** — first match
  wins, so order is semantic), a portal card, and a permanent pattern sweep
  in the test suite. Publication remains a deliberate act.

## 2.0.64 - 2026-08-15

### Fixed — fresh installations no longer lock the installer out

- **The `csadmin` support account was never created on a freshly imaged box.**
  On a fresh clone `cs_update` regenerates its config while Home Assistant is
  still in recovery mode — before the box UUID exists — so it baked the
  placeholder `no-guid` into the GUID the internal calls carry. Every
  guid-authenticated call, including the boot-time `csadmin` sync, was then
  rejected (403) and the account never appeared. The add-on now publishes the
  real GUID and ensures `csadmin` in-process as soon as the box has an identity,
  retrying until Home Assistant's API is ready.
- **A freshly cloned box could get stuck in recovery mode indefinitely.** A
  Core restart requested too early (while Core was still doing its first boot)
  failed silently and was never retried, leaving the box in recovery with no
  usable config. Failed restarts are now recorded and retried, and the add-on
  forces a single Core restart as a backstop if the box has not left recovery.

### Fixed — security & gold hygiene

- Factory-reset and tenant-reset endpoints now require a real credential (a
  forged `context=lovelace` marker is no longer accepted).
- Closed a path where the `casasmooth_proxy` component could relay owner-only
  internal endpoints from the public tunnel.
- The golden image is now depersonalised at capture: household accounts,
  credentials, refresh tokens and the tunnel state are stripped, so a clone
  boots with a clean identity instead of inheriting the source unit's.

### Fixed — the nightly update no longer runs stale code

- The 02:00 regeneration ran inside the long-lived add-on process, using the
  modules imported at boot rather than the code on disk. After a deploy without
  an add-on restart it could re-emit pre-fix configuration (this is what pushed
  an office shutter to 100 % overnight). It now runs as a subprocess against the
  on-disk code, and `cs_deploy` decides the restart from the last deployed SHA.

### Changed — per-shutter calibration model

- Shutter control moved from a single inversion flag to a **coverage %** driven
  by two per-shutter position anchors (clear / covered), so both normal and
  reverse-counting shutters are handled by the same mapping. Fresh boxes get
  safe defaults (full travel, non-inverted). ⚠️ **On an upgrade, a shutter that
  was configured as inverted may move the wrong way until its two anchors are
  set** — recalibrate any automated/inverted shutter after updating.

### Added / improved

- Mobile app: casasmooth brand theme, voice assistant integrated into every tab
  (the eye overlays on the mic), real-scale 3D floor plan with hover tooltips,
  tap-to-toggle on touch and swipe between tabs, broader i18n.
- Loxone integration vendored (LAN-only, opt-in — dormant unless provisioned).
- Numerous SmartGridready, EMS, MCP, notifications, PWA/Web Push and translation
  fixes.

## 2.0.63 - 2026-08-06

### Fixed — a stale cloud rules payload could silently disable whole categories

- The rules-service was serving 227 categories against the 278 shipped in
  `app/data/cs_rules.csv`. Outside development mode the generator overwrites
  `locals/cs_rules.csv` with that payload at every update, so 51 categories
  were absent on any box that ran it — among them `glass_break_sensors`,
  `gas_sensors`, `tamper_sensors` and `water_valves`. Every lookup keyed on
  those names returned an empty list, so the glass-break, gas and tamper
  handling and the water cut-off alert had nothing to act on. Nothing failed
  loudly, which is why it went unnoticed.
- The fetch now compares the incoming payload against the bundled categories
  and **refuses** one that loses any of them, keeping the rules shipped with
  the deploy. The service stays free to *add* categories — that is its purpose.
- The service database itself was re-imported from the bundled CSV, so it
  serves the full set again.

### Changed — the category guard now covers every lookup

- `test_category_names_exist.py` only checked two hand-maintained lists. It now
  walks the AST of everything under `app/` and validates all 169 literal
  `get_entit*_by_category` arguments, against both `cs_rules.csv` and the
  categories `cs_registry` creates itself when reclassifying switches
  (`bulbs`, `heaters`, `fans`, `power_outlets`). No dead literal lookup remains.
- Known gap, tracked in `BACKLOG.md`: 38 call sites pass the category through a
  variable and stay outside the guard.

## 2.0.62 - 2026-07-22

### Fixed — dashboard gating & cleanup on freemium/empty installs

- EMS dashboard is now gated on `enhanced_energy`. It used to be generated
  unconditionally and appeared in the sidebar even on freemium, where it
  has no data to drive (it is the active energy-management product: SGr
  device control, load-shifting, cost-of-mix). Returning no view makes the
  generator skip the whole `cs-ems` dashboard, so the staging→prod prune
  removes it from the sidebar too.
- System view no longer renders a "No WOL device defined" empty-state card.
  Wake-on-LAN (an `enhanced_base` feature) now shows its settings toggle,
  settings tile and section together — or all three are omitted when the
  install has no WOL entities. No stray card/toggle on freemium.
- Dropped the `cs_dummy_switch_to_avoid_errors` template switch. It had no
  backing `input_boolean`, was referenced by nothing, and surfaced as a
  stray switch entity on empty installs. The dummy *sensor* is kept — it is
  the source for the utility_meter/integration stubs and already keeps the
  modern `template:` list non-empty.
- Removed the dead "Setup guide" link (`manuals#getting-started`, a page
  that does not exist) from the empty-system Welcome panel.

## 2.0.61 - 2026-07-15

### Fixed — remote-access tunnel: never permanently give up on crash-loop

- `tunnel_service`'s `frpc` supervisor used to exit for good after 5 fast
  login failures in a row, on the assumption that the HA addon supervisor
  would restart the parent process. Nothing actually monitors this
  fire-and-forget subprocess, so a transient cloud-api blip during a
  reconnect attempt could kill remote-access connectivity permanently
  until the next full addon restart or update. Now it cools down for
  15 minutes and resumes retrying instead of exiting.

## 2.0.60 - 2026-07-15

### Feature — EMS: weather-service fallback, light/dark theme, restructure into 5 tabs

- Weather card now falls back to the HA weather service, per-metric
  (temperature/humidity/wind/pressure), whenever weather-flagged zone
  sensors are missing wholly or partially — with a `source` marker and a
  dimmed/tooltip treatment so fallback values are visibly distinguished
  from real zone readings.
- Added a self-contained light/dark theme toggle to the EMS mobile
  dashboard (was always dark), independent of the app's separate 5-theme
  picker — refactored `ems-view.css` onto CSS custom properties scoped to
  `.ems-view`/`.ems-light`, persisted via `localStorage`.
- Restructured the EMS dashboard into 5 tabs, added collapsible
  (persisted) cards across all of them, weather history as a ranged chart
  aligned to the energy timeline, richer real recommendations, help
  pastilles with tap popovers, expert mode, and a link to the hosted GRD
  simulator from the Réseau (grid) tab.

### Feature — GRD (grid operator) remote simulator, phases 0-5

- Per-system opt-in gate for remote GRD signal simulation, propagated via
  heartbeat; `sgr_webhook_token` now authenticates simulator signals over
  the tunnel; bridled duration/priority for simulator-originated signals;
  cloud-api OTP + signal relay + audit poll; real `grd_simulator.py`
  dashboard UI ported to casasmooth.net/grdsimulator, with a remote-sim
  opt-in tile and fixed silent send failures.

### Feature — Fleet Portal (multi-tenant / building-manager self-service)

- Generalized `Building` into `FleetGroup` with a login-capable manager;
  added a self-service Fleet Portal app with a real MFA challenge flow;
  group-level services override (additive, admin/portal-only), unified
  ownership-change handling, and automatic subscription cancellation on
  handover; server-side and admin-endpoint activation scripts for
  granting/revoking fleet-manager access.

### Feature — KNX (.knxproj) import tool

- Added an ETS project import tool with review/apply/rollback, redesigned
  onto EMS's visual language; fixed a missing `aiofiles` dependency and
  made the area-picker degrade gracefully when ETS data is incomplete.

### Feature — casasmooth intent triggers (purpose-specific automation events)

- Added 26 intent triggers across security, presence/access, energy/EV,
  and comfort domains, backed by a single-source-of-truth manifest and
  codegen (`intent_triggers.json` → `triggers.yaml`/`strings.json`/
  translations); migrated `telemetry.py`, `occupancy.py`, `scheduler.py`,
  and `cs_load_shift.py` onto the new `fire_intent_event()` helper. All
  verified live on `.149`.

### Fix — `cs_car` dashboard didn't recognize/display OBD-bridge or
multi-vehicle setups (6-commit cascade, all verified live on `.149`)

- The vehicle-presence gate only matched EV-with-battery-style entities;
  now recognizes anything in the `ev`/`car` registry dashboard groups, so
  OBD-bridge-only vehicles (no native cloud integration) are picked up.
- Fixed phone-consolidation logic that was silently discarding a second
  real vehicle's data behind the single Android-Auto-consolidated tile.
- Tiles are now always labelled with their device name when more than one
  source shares a metric category, and the whole page/sections/toggles are
  named after a real vehicle (native integration or OBD bridge), never a
  paired phone.
- Phone/Android-Auto tiles are dropped entirely once any real vehicle
  exists, instead of being relabeled.
- Empty category cards and their now-pointless show/hide toggles are
  hidden live via HA visibility conditions (registry has no live entity
  state to decide this at build time).

### Fix — SGr, tunnel, migration, deploy reliability

- `tunnel_service`: never permanently give up after a crash-loop.
- Migration 096's revision id was too long and crash-looped `cloud-api` on
  deploy; shortened it.
- `sgr_kpi()` crashed on `period=month/year/all` (referenced undefined
  config); `deploy-all`'s website health probe now shares the `.ps1`
  fallback; docker-compose v1 `ContainerConfig` `KeyError` on website
  recreate fixed by routing nginx at compose aliases instead of container
  names.

### Refactor — split `server.py` / `cloud_api` god-objects into routers

- Extracted `sgr_ems`, `mobile_api`, `semantic_exposure`, `assistant_chat`,
  `ai_automation_api`, `onboarding`, `validation_api`, `diagnostics_api`,
  `matter_bridge`, `floorplan_3d` (HA addon side) and `content_marketing`,
  `auth_users`, `contacts_tickets`, `admin_systems`/`admin_services`,
  `crm_billing`, `blog`, `landings`, `website_catalog`, `llm_config`, and
  the telemetry router (cloud-api side) into standalone modules; split
  `cs_automations.py` into domain modules. Internal only — no behavior
  change intended.

## 2.0.59 - 2026-07-06

### Fix — SGr audit fixes (claims summary, read_sync, MQTT connect, optimizer proxy guard)

- `sgr_rules_engine`: claims summary was reading the wrong JSON key
  (`devices` instead of `claims`), so it stayed stuck reporting "no claims";
  guarded the optimizer watts override from clobbering virtual proxy
  SG-Ready states.
- `sgr_service`: added the missing `read_sync` method (the MQTT bridge
  referenced it, but only the mock implementation had it — real devices
  never actually synced); capture the connect-time event loop for
  cross-thread dispatch.
- `server.py`: the MQTT bridge now calls `connect_all()` on devices before
  announce/publish (was always iterating 0 connected devices); aligned the
  4 inline `sgr_audit.json` event writers to append+`[-288:]`, matching the
  rules engine and readers.
- Added regression test coverage for claims summary, `read_sync`, and the
  optimizer proxy guard.

## 2.0.58 - 2026-07-06

### Fix — `sgr-commhandler` (SmartGridReady Modbus/EID library) was never installed in production

- **Root cause**: `sgr_service.py` has depended on the `sgr-commhandler` PyPI
  package since it was introduced (Modbus TCP / REST device control via EID
  XML profiles — `_connect_device`, `_resolve_eid`, etc.), but the package
  was declared **nowhere** in the real install pipeline: absent from
  `pyproject.toml` `[project.dependencies]`, absent from the addon's
  `addon/build/Dockerfile.production` `pip3 install` list (the one actually
  used to build the production image via `.github/workflows/build_addon.yml`),
  and absent from `install_deps.sh` (which only installs other HA add-ons —
  Mosquitto, SSH, Whisper, Piper — no pip packages). It only appeared in a
  docstring comment (`Requires: pip install sgr-commhandler>=0.5.0`).
  `SGrService.__init__` defensively catches the resulting `ImportError` and
  silently sets `available = False` — so instead of a loud crash, every SGr
  Modbus/EID feature was quietly a no-op in every production install. No
  Modbus/EID device (Fronius, WAGO, Kostal included) was ever proven
  functional through SGr; the test suite didn't catch it because every SGr
  test mocks `sgr_commhandler` via `sys.modules` instead of using the real
  package.
- **Fix**: added `"sgr-commhandler>=0.5.0"` to `pyproject.toml` and to the
  `pip3 install` list in `addon/build/Dockerfile.production`.
- **Test**: added `TestRealPackageInstalled` to
  `app/tests/test_sgr_library_integration.py` — the only test class in the
  SGr suite that does NOT monkeypatch `sgr_commhandler`, so a future
  packaging regression fails loudly instead of hiding behind mocks.

## 2.0.57 - 2026-07-06

### Fix — offboarding (factory reset / device cleanup) was non-functional end-to-end

- **Cloud API**: `factory_reset()` called two cloud endpoints
  (`/api/tunnel/revoke`, `/api/systems/dissociate`) that didn't exist —
  they 404'd silently and the function still reported success. Added both
  routes (`app/api/tunnel.py`, `app/api/systems.py`), authenticated via the
  system's own Bearer token. Fixed call order in `onboarding_service.py`
  (dissociate before revoke — revoke invalidates the shared Bearer) and now
  captures the cloud auth headers before wiping local tunnel state.
- **HA dashboard**: "Nettoyer les appareils" / "Réinitialisation usine"
  buttons only called `input_button.press` with no automation reacting —
  pressing them did nothing. Added `rest_command.cs_factory_reset_run` /
  `cs_cleanup_devices_run`, new loopback-only `/api/internal/factory_reset`
  + `/api/internal/cleanup_devices` endpoints, and two new automations
  wiring the buttons end-to-end. Factory reset now shows a native
  confirmation dialog (irreversible action).
- **Mobile app**: no UI existed at all for these actions. Added a
  "Maintenance" section to Settings (cleanup devices + factory reset with
  double confirmation).

## 2.0.56 - 2026-07-04

### Fix — deferred Home Assistant Core restart lost after cooldown

- **Root cause**: the add-on runs with `startup: application`, so Home
  Assistant Core always finishes loading `configuration.yaml` before this
  add-on even starts. `cs_update` regenerates the file and asks Core to
  restart to pick up changes (e.g. `http.trusted_proxies`) — but if that
  restart was deferred by the 10-minute cooldown, it was lost forever: the
  next `cs_update` run sees no NEW file diff (it already wrote the fix) and
  never re-requests the restart. Symptom: HA rejects every tunneled request
  with `400: Bad Request` / `Received X-Forwarded-For header from an
  untrusted proxy`, indefinitely, until an unrelated restart happens to occur.
- **Fix**: a persisted `cache/cs_pending_restart.json` marker now survives
  across runs. Any restart deferred by cooldown is retried on every
  subsequent `cs_update` — independent of file-diff detection — until it
  actually succeeds, then the marker is cleared.

## 2.0.55 - 2026-06-23

### Matter bridge upgrade & admin translations

- **Matter 1.4 support**: upgrade `@matter/node` from 0.12 to 0.16 — supports
  Matter 1.4.2 spec (new device types: EV chargers, water heaters, appliances,
  Scenes Management cluster, OTA updates). Explicit `colorTempPhysicalMinMireds`
  / `colorTempPhysicalMaxMireds` set for ColorTemperatureLightDevice (required
  by Matter 1.4, defaults were removed).
- **Matter bridge in dev_mount mode**: `run.sh` now runs `npm install` once on
  first boot in dev mode so the Matter bridge works without a Docker image
  rebuild. Stamp file prevents re-running on every restart.
- **Admin dashboard translations**: added 11 missing translation keys for the
  Services, Maintenance, and Matter sections (5 languages). Matter section now
  shows an explanatory text when the bridge is not running instead of a blank
  space.

## 2.0.54 - 2026-06-19

### Fix — Shelly detached mode: protect Zigbee bulbs behind wall switches

- **Detached wall_switch detection**: new `get_detached_wall_switches()` in the
  registry identifies Shelly switches that coexist with Zigbee/smart lights in
  the same area. Detection uses the Shelly `select.*_switch_type` entity
  (detached/momentary) when available, falling back to a device-id heuristic
  (wall_switch on a different device than the area's `light.*` entities).
- **Relay exclusion from lighting actions**: detached wall_switches are excluded
  from `_build_lighting_turn_on_actions`, scene save/restore, and the wallswitch
  toggle automation targets. HA no longer sends `turn_off` to the Shelly relay
  when a Zigbee bulb sits behind it — preventing mesh disconnection.
- **Relay guard automation**: a per-switch `CS - Relay Guard - <name>` automation
  re-enables the relay within 2 seconds if it is turned off accidentally (power
  glitch, firmware reset, manual override), keeping the Zigbee bulb powered.
- Wall_binary_sensor triggers (physical button press) continue to work unchanged
  — they toggle the area's `light.*` / bulbs / relay-mode switches only.

## 2.0.53 - 2026-06-18

### Fix — Security sensors & phantom-entity warnings

- **Home security section parity**: the per-area "security sensors" section on
  the home dashboard now exposes the same categories as the dedicated security
  view, from a single source of truth
  (`DashboardBase.SECURITY_SENSOR_CATEGORIES`). Door/window open sensors — plus
  water, smoke, vibration, gas, CO, tamper and noise sensors — were previously
  missing from the home view (only motion/occupancy/presence were shown).
- **Automatisations warning triangle removed**: each area's "Automatisations"
  placeholder no longer references `input_button.cs_<area>_empty_button`, an
  entity that is never created. Home Assistant rendered it as an "unavailable"
  warning (⚠️) in every area whose automation buttons are gated off (e.g. no
  lighting subscription). The placeholder is now an inert, entity-less tile.
- **Broken Low Disk Alert automation removed**: "CS - System - Low Disk Alert"
  triggered on `sensor.cs_ha_host_disk_free`, an entity that is never created,
  so HA flagged it as an unknown-entity error and it never fired. Low-disk
  alerting is already covered by "CS - System - Storage Problem Detection"
  (`sensor.system_monitor_disk_use`).

## 2.0.52 - 2026-06-17

### Maintenance

- Version bump, no functional changes.

## 2.0.51 - 2026-06-14

### Fix — Enhanced lighting: false-occupancy guard + illuminance-based turn-off

Two lighting reliability fixes, already validated in production.

- **False-occupancy guard**: every sensor-driven lighting trigger
  (motion, occupancy, presence, door/open, camera, TV) now requires
  `trigger.entity_id is defined` **and** `is_state(trigger.entity_id, 'on')`
  before acting. This stops automations from firing on an undefined or
  stale trigger context, which could switch lights on without a real
  detection.
- **Illuminance-based turn-off (hysteresis)**: new per-area automation
  that turns auto-lit lights off once ambient `avg_illuminance` rises above
  the turn-on threshold × 1.3. Closes the gap where a presence-gated zone
  kept its lights on indefinitely in broad daylight (the enhanced ON path
  only adds light and the regular OFF path only reacted to timer/sustained
  sensor-off). The 1.3 hysteresis margin prevents on/off oscillation, and
  the automation only acts in presence-gated mode while the lights are still
  owned by `auto` (never fighting a manual or scene override).

## 2.0.50 - 2026-06-07

### Fix — template integration off the deprecated `platform:` key

Home Assistant core (2026.6) no longer supports configuring the template
integration via the legacy `sensor: - platform: template` /
`switch: - platform: template` keys.

- All real template sensors/switches already used the modern `template:`
  integration; only the internal dummy entities
  (`cs_dummy_sensor_to_avoid_errors`, `cs_dummy_switch_to_avoid_errors`)
  were still emitted as legacy `- platform: template`.
- Those dummies are now generated under the modern `template:` integration,
  and `cs_sensor.yaml` / `cs_switch.yaml` are emitted as valid empty lists.
- No functional change for end users; clears the "Unsupported YAML
  configuration for the template integration" repair warning.

## 2.0.49 - 2026-05-24

### Security — Round 7 + Round 8 + Round 8 Niveau 2

Continuation of the 2.0.48 lockdown. Three further rounds of hardening,
plus an MFA reminder on the addon side. No functional change for end users.

**Round 7 — security-advisor MFA reminder (HA-side)**
- New advisor flow detects interactive HA accounts that haven't enrolled
  in TOTP and nags via persistent notification + email. Filters out
  `system_generated` accounts (Supervisor, Cast bridge, ...) and reads
  the correct HA 2024+ auth schema:
  `auth.data.credentials[].user_id` (top-level array) + the singular
  `auth_module.totp` storage file.
- i18n: 6 new keys in `cs_translations.csv` (FR/EN/DE/IT/CS).
- Three-layer anti-spam on the camera-offline advisor: 15-min
  `binary_sensor` debounce + 2-min trigger `for:` + 6-hour cooldown.

**Round 8 — HA LLATs encrypted at rest on the cloud DB**
- `app/utils/secret_box.py`: Fernet wrapper with `enc:v1:` prefix and
  `MultiFernet` rotation support. `cryptography>=42` added.
- Migration 085 encrypts existing `systems.remote_token` in place and
  scrubs the duplicate copy that was leaking into `systems.extra_data`
  via the heartbeat merge.
- Pydantic `field_validator` on `SystemResponse.remote_token` so every
  endpoint that returns the model decrypts on the way out.
- `STRICT_API_AUTH` boot guard: cloud-api returns 503 on `/health` when
  either `CASASMOOTH_DB_FERNET_KEY` or `STRICT_API_AUTH` is missing, so
  monitors page on misconfiguration.
- `cs-deploy` learned both env vars + a `_ensure_fernet_key` helper that
  auto-generates a Fernet key on first deploy and persists it to depot
  at `casasmooth-internal/db_fernet_key`.
- Removed the hard-coded `ADMIN_WEB_PASSWORD` default
  (`csadmin!0301040105`) from operations-portal + compose — it was
  readable from the repo.
- Verified in prod: 13/13 `systems.remote_token` rows are `enc:v1:` at
  rest, 0 plaintext leftover in `systems.extra_data`.

**Round 8 Niveau 2 — per-admin accounts + TOTP MFA + audit log**
- Shared `csadmin` / `ADMIN_TOKEN` retired in favour of per-admin
  identity. Admins live in `website_users` (role=`admin`),
  `password_hash` is PBKDF2, `totp_secret` is Fernet-encrypted at rest.
- Migration 086: `admin_audit_logs` records every admin mutation
  (action, target, method/path, status, IP, user-agent, admin identity).
  FastAPI middleware auto-appends one row per `/api/admin/*` +
  `/api/systems` write.
- `admin_api_tokens` stores per-admin API tokens (sha256 only).
- Two-step login (email+password → TOTP) on `/portal/login` and
  `/crm/login`. Lockout after 5 consecutive failures.
- New CLI: `python3 -m app admin {create|list|reset-totp|reset-password|token|audit}`.
- Three admins provisioned + verified live (crohrbach@teleia.ch,
  lrohrbach@teleia.ch, christine.rohrbach@hotmail.com).

## 2.0.48 - 2026-05-22

### Security — full backend lockdown (6 audit rounds, ~40+ vulnerabilities closed)

This is a security-only release. No functional change for end users; the
addon should pull and restart transparently.

**Per-system Bearer auth on cloud-api**
- `Authorization: Bearer <token>` (the cs-remote tunnel secret, already on
  every HASS at `/data/tunnel/frpc.toml`) is now required on:
  `/api/files/{backup,restore,list}`, `/api/secrets`, `/api/email/send`,
  `/api/diagnostics`, `/api/heartbeats/{guid}`, `/api/metrics/llm`,
  `/api/audit/llm`, `/api/telemetry/reports`, `/api/tunnel/slug`,
  `/api/systems/{guid}/migration/confirm`, `/api/llm/config` (GET),
  `/api/systems/{guid}` (GET), `/api/subscriptions/{guid}`,
  `/api/services/{guid}`, `/api/tunnel/provision` (when re-fetching
  frps_token for an already-provisioned system).
- Constant-time `hmac.compare_digest` on token comparison.
- Anti-brute-force auto-lock: 50 fails from a single IP OR 200 globally
  per hour (was 10 across all IPs — a known guid + cheap script could
  lock any tenant's tunnel).

**Admin-only on cloud-api writes**
- `GET /api/systems` list, `PUT /api/bridging/{guid}`,
  `POST /api/llm/config`, `GET /api/llm/config/history`, all `/api/admin/*`.

**HASS-side (server.py) AuthMiddleware**
- Tunnel traffic (`<guid>.casasmooth.net`) no longer satisfies
  `is_internal_host` or `X-Casasmooth-Context: lovelace` bypasses — both
  short-circuited the entire cs API auth.
- `/api/internal/*` removed from PUBLIC_PREFIXES (was allow-listed with a
  fake "guarded by localhost check"). An attacker could call
  `/api/internal/sync_csadmin_password` via the tunnel to RESET the HA
  admin password. Now AuthMiddleware enforces loopback + RFC1918 origins,
  and `sync_csadmin_password` adds a hardened
  `_verify_internal_request_origin` defence-in-depth.
- `POST /api/auth/config` (the disable-the-whole-middleware switch) is
  now loopback-only.
- CORS regex tightened — `allow_origins=["*"] + allow_credentials=True`
  (spec violation) replaced by a regex that accepts only
  `*.casasmooth.net` + RFC1918 + .local.

**Side services**
- rules-service: HTTP middleware gates every admin path;
  `/api/entities/{report,uncategorized}` require per-system Bearer.
- logs-service: `POST /api/logs` requires Bearer; reads + management
  endpoints require admin.
- upload-web (`/upload/api/*`): was UNAUTHENTICATED with path-traversal
  on `csuuid` — now Bearer per-system + UUID-regex + filename
  sanitisation + resolved-path containment.
- image-ai (`PUT /api/camera/upload`): strict devuuid regex (rejects
  `..`) + enrolment check + 50 MB cap.

**Token mirror**
- `tunnel_service` mirrors the per-system token at boot to
  `/config/casasmooth/locals/cs_tunnel_token` (mode 0600). HA Core /
  shell_command callers (which can't see the addon's `/data/tunnel/`)
  read it from there. Done BEFORE frpc binary check, so the file appears
  within milliseconds of addon start (avoids race with `cs update`).

**Heartbeat payload guard**
- POST /api/heartbeats caps each capability model (semantic / gap /
  functional) at 10 MB (was unbounded → DB-pollution / DoS risk).

**Infrastructure**
- Azure PG firewall: removed `AllowAzureServices` (was allowing every
  Azure tenant) — kept only the VM IP + admin IP.
- Azure PG admin password rotated; pushed to depot
  (`azure-cloud/db_password`) and propagated to the VM `.env`.
- nginx rate-limiting added in repo (heartbeats / login / files /
  api_general) — deferred deploy until the Infomaniak migration is
  complete (current Azure default.conf has diverged).

**Tooling**
- New `cs-deploy github sync-secrets` — pushes depot secrets
  (ADMIN_TOKEN, LOGS_SERVICE_URL) into GitHub Actions repo secrets so
  workflows like `analyze_logs.yml` can authenticate against logs-service.
- `scripts/dbcheck.py` no longer carries the DB password in cleartext;
  resolves DATABASE_URL from depot.

**DB cleanup**
- 34 stale systems (last_seen <2026 OR never-seen) removed via the
  proper `DELETE /api/admin/systems/{id}` cascade.

## 2.0.47 - 2026-05-22

### Lighting exception — fix scene-to-scene transitions in contiguous schedules
- **Bug**: in `cs_parameters_<area>_update_current_values` (UCV), the two
  template triggers `{{ ns.scene > 0 }}` and `{{ ns.scene <= 0 }}` only fired
  on the boolean's `false→true` edge — not on changes of the underlying
  `ns.scene` integer. With contiguous schedules like
  `s1:8-9 s2:9-18 s3:18-22 s4:22-23`, every internal boundary (09:00,
  18:00, 22:00) was silently skipped: the boolean stayed `True` across
  the transition, so HA never re-evaluated UCV and the new scene's
  `restore_scene_<N>` button was never pressed.
- **Observed on a client installation 2026-05-22**: s1→s2 at 09:00 was missed on all 7
  areas. Anne had to manually click `restore_scene_2` on each area at
  09:37 (and again 2 of 7 areas at 08:34 because the s1 batch had been
  partial). Same root cause across the whole client fleet using
  multi-window day schedules.
- **Fix** (`app/core/cs_automations.py`): replace the 2 boolean triggers
  with 11 targeted ones — `{{ ns.scene == 1 }}` … `{{ ns.scene == 10 }}`
  (one per scene) plus a single close `{{ ns.scene == -1 }}`. Each fires
  its own rising edge as `ns.scene` enters its window, including the
  s1→s2, s2→s3, … transitions. First-match-wins overlap semantics in the
  Jinja parser are unchanged.
- **Validation on .149 bureau** (test schedule `s1:11:07-11:08 s2:11:08-11:09`):
  - 11:07:50 → `restore_scene_1_in_bureau` fired (window open ✓)
  - 11:08:09 → `restore_scene_2_in_bureau` fired (contiguous transition ✓
    — would never have fired with the old triggers)

## 2.0.46 - 2026-05-22

### Remote tunnel — fix multi-tenant proxy name collision
- **Bug**: every frpc rendered `name = "hass" / "cs-api" / "mcp"` in its
  `frpc.toml`. In frps, the proxy `name` is a server-global key, so the
  second client to connect was rejected with
  `new proxy [hass] error: proxy [hass] already exists`. With 14 systems
  declaring `tunnel_status=connected` in DB, **0** had a working HTTP
  route — including `.149` (the Phase 1 reference). Every public host
  (UUID and slug) returned 404 `no route found` at frps.
- **Fix** (`app/services/tunnel_service.py`): prefix each proxy name with
  the system GUID so frps sees a unique key per client:
  `name = "{guid}-hass"` (resp. `-cs-api`, `-mcp`). The auth plugin
  (`/api/tunnel/auth`) does not key on proxy name, so the change is
  transparent server-side; nginx → frps vhost routing is by host header
  only, also unaffected.
- **Rollout**: `.149` (dev_mount) picks up the new template on next addon
  restart. Existing client installations need this new
  image; frps is restarted to purge phantom proxy registrations.

## 2.0.45 - 2026-05-22

### Frigate / camera health alerts — admin-only (no more client emails)
- **Bug**: three technical alerts emailed/notified the client even though
  they are pure admin/maintenance concerns:
  - `CS - Surveillance - Frigate Offline Notification` — sent an explicit
    email to `info@casasmooth.com` AND a `_create_notification_actions(PAM)`
    block whose `M` channel routed a second email to
    `input_text.cs_user_email` (the client).
  - `CS - Surveillance - Frigate Auto Restart` (escalation branch on
    excessive restarts) — same double-send pattern.
  - `CS - Security - Camera Offline Alert` — had **no** admin email at
    all, only a `PAM` block notifying the client (dashboard + app + email).
- **Fix** (`app/core/cs_automations.py`):
  - Drop the `_create_notification_actions(...)` block on all three.
  - Keep / add a single `rest_command.cs_send_email` targeting
    `info@casasmooth.com`, with the customer's email surfaced in the
    subject and body for triage.
  - Client now receives **zero** dashboard / app / SMS / email signal on
    Frigate Offline, Frigate Excessive Restarts and Camera Offline.
- **Out of scope** (unchanged): security alarms, lock failures, freezer
  alerts, Low Disk and Getservices Stale — those remain customer-visible
  per existing UX.

## 2.0.44 - 2026-05-19

### Per-area config cards — gate aligned with automation sensor union
- **Bug**: room-level config cards (Lighting / HVAC / Security) only opened
  on a subset of the sensors their underlying automations actually use. A
  room with **only** an mmWave radar (`presence_sensors`) — or **only** a
  vibration sensor for security — had the corresponding "Paramètres" panel
  hidden even though the automation worked.
- **Fix** (`app/core/dashboards/cs_home/cs_home.py`):
  - **Lighting**: fetch `presence_sensors` at the call-site and pass a new
    `has_persistent_presence` flag. The "Automations avancées" gate is now
    `motion ∪ open ∪ occupancy ∪ presence(mmWave)` — same union as
    `cs_automations.py` `all_devices`. `is_mixed_zone` corrected to use the
    flag (was using the multi-zone-filtered list). Redundant `has_camera_sensors`
    OR removed (camera is a subset of motion).
  - **HVAC**: `area_presence` now includes `presence_sensors` — matches
    `cs_automations.py` heating `presence_sensors = motion + occupancy + presence`.
  - **Security**: `area_security` now includes `presence_sensors` and
    `vibration_sensors` — matches the "Verify security sensors" automation
    triggers. Smoke / heat / moisture / noise stay out (notification-only,
    no UI to configure).

## 2.0.43 - 2026-05-19

### Security view — occupancy + presence sensors restored
- **Bug**: 5 call-sites queried `all_occupancy_sensors` as if it were a
  meta-aggregate, but `cs_rules.csv` only assigns this category to
  Frigate "all occupancy" virtual sensors. All other occupancy-tagged
  sensors (IKEA Matter MYGGSPRAY, IKEA Zigbee VALLHORN, Philips Hue
  SML003, Frient MOSZB-153, Aqara FP2…) fall under the generic
  `occupancy_sensors` category and were never reached by the security
  dashboard or security automations.
- **Fix**: aligned the 5 call-sites on the existing atomic-enumeration
  convention (`motion_sensors` + `occupancy_sensors` + `presence_sensors`)
  used everywhere else in the codebase.
  - `cs_security.py` — section "Présences" of dashboard Sécurité,
    recommendations engine relevant_categories.
  - `cs_home.py` / `cs_dashboards.py` — area_security tile.
  - `cs_automations.py` — camera occupancy fallback + per-area
    `verify_security_sensors` automation triggers.
- **Data files** — renamed `all_occupancy_sensors` → `occupancy_sensors`
  in `feature_requirements.json`, `site_context.json`, `chat_knowledge.json`,
  `cs_translations.csv`, plus the website mirrors. Added the missing
  `help_device_presence_sensors` translation. `cs_rules.csv` rule 164
  (Frigate-specific) kept intact.
- **Effect**: occupancy/presence sensors now feed (a) the "Présences"
  section of the security dashboard, (b) the per-area
  `verify_security_sensors` automation that increments the global event
  counter, (c) the recommendations engine. The lighting path already
  used the atomic category name and is unchanged.

## 2.0.42 - 2026-05-17

### LLM gateway — cloud-managed routing
- **Infomaniak primary + OpenRouter fallback** rolled out across all
  purposes (chat, conversation, translate, recommendations, blog,
  catalog, rules, features). Per-provider circuit breaker, per-purpose
  provider chain, provider-aware metrics. Ministral-3 14B replaces
  Apertus everywhere on Infomaniak (Apertus 20k context overflowed on
  long prompts).
- **Cloud-managed routing config**: the per-purpose model map is now
  edited in the operations portal and pushed to addons — no addon
  redeploy needed to retune chat/conversation models. Editor seeds from
  baked-in defaults when DB is empty; portal page gains
  provider/call_type/model filters on `/llm-metrics`.
- **Weekly model-availability monitor**: cron at Mon 08:00 UTC mails an
  advisory report to info@casasmooth.com (replaces the GH Actions
  workflow).
- HA Extended OpenAI Conversation now routes through the casasmooth
  gateway. OpenRouter chat model switched to `deepseek-chat`.

### Voice assistant (Jarvis / Assist) — accuracy hardening
- **Zone-filtering**: prompt now only includes the area(s) mentioned in
  conversation instead of dumping the whole house.
- **Per-area sensor section** with **UoM-first classification**:
  semantic model enriched from the entity registry, locale-independent
  unit-of-measurement → category map, FR/EN name tokens dropped. Unit
  shown in prompt. Fixes "0 lux" hallucinations on FR-named sensors.
- **Anti-hallucination guards**: new `get_entity_state` template tool
  (was referenced by prompt but missing); prompt now mandates calling
  it before any state claim; anti-sycophancy rule + context continuity.
- **Sensor filtering**: nightly `_sleep_avg_` aggregates excluded from
  both prompt sensor section AND HA exposed_entities (single
  `_is_realtime_for_llm` predicate). Prevents DeepSeek from hallucinating
  tool names against stale aggregates.
- **Topic policy** broadened with weather examples; web-search wired
  via `cs_search_web_technical`; tool rename
  `search_casasmooth_website` → `casasmooth_help` (LLMs were collapsing
  the double-s on the old name).
- **STT fallback to HA Cloud** on CPUs without X86_V2 (faster_whisper
  crashloop on Proxmox kvm64 default).
- **Devices grouped by semantic category**, not HA domain, in prompt.
- **Voice/conversation model swap**: chat_model now sourced from the
  dedicated `CASASMOOTH_ASSISTANT_MODEL` secret. Fix: setup_voice
  (step 15) no longer overwrites setup_conversation (step 14).
- KB recompiled + prompt hardened for the site chat as well.

### AI Automations — IR-based v2
- New triggers/conditions/actions schema with arbitration, package
  helpers, and boot-time sync. End-to-end wiring: HA Core tool
  dispatch, unique IDs, registry preload, manual trigger path.
- **Voice-driven CRUD**: `quick_create_ai_automation` (draft+confirm in
  one tool), `bulk_delete`, slugified entity_id for test_run.
- Arbiter release on delete/disable. Persistent path. ai_custom
  lighting rank. Owner entities + REST endpoints.

### cs-deploy — unified CLI
- New `cs-deploy` Python CLI replaces the PowerShell + Bash deploy
  scripts. `deploy-all` command (combined Azure + HASS + health).
  Containers cmd parameterized for Azure + Infomaniak.
- `blob_migrate` + `maintenance` modules for the Azure → Infomaniak
  cutover. Cron sync module (idempotent BEGIN/END markers).
- SCP fallback via `ssh cat` for SCP-disabled hosts (.149); utf-8 +
  `errors=replace` on captured subprocess output.

### docs/build — unified content pipeline
- Generic pipeline orchestrator + `build_content` for presentation,
  technical, website. Hash-cache, separated config/output, depot vault
  lookup. Brand-aligned HTML/PPTX rendering. Source fragment hints +
  larger context window. Switched to gemini-2.5-pro.

### Cloud-api Phase 2
- Eliminate `SecretsCacheService`; secrets served from disk.
- Logs-triage Phase A: promotion filters + bulk-ignore.
- CI: stop cascading website redeploys + public-URL watchdog.
- Watchdog log: clean failure-code formatting (000000 → 000).
- Migrate Azure-specific FQDN to `api.casasmooth.net`.

### Energy / SGR
- Add management summary for the energy domain.
- SGR: align with SmartGridReady spec, add MQTT discovery bridge.

### Misc fixes
- **Frigate addon**: dynamic slug + Supervisor REST replaces broken
  `ha addons restart`.
- **Billing**: replace "TVA incluse"/"TTC" → "Sans TVA" across site,
  CRM, emails and quotes.
- **Voice notifications**: Jinja2 broken on gas alerts + dedup 3
  hardcoded TTS blocks.
- **API**: remove duplicated `/api/matter/entities` endpoint.
- **Zone-scene UI**: title global panel + disambiguate duplicate zone
  labels.
- **nginx**: route `/api/*` directly to image-ai for ESP32 cameras.
- **Ops**: close cleanup gap — disk hit 100% + cs-deploy was not
  shipping crons.

## 2.0.41 - 2026-05-11

### Lighting — extinction strategy overhaul
- **Categorization rules (cs_rules.csv)**: VALLHORN / MYGGSPRAY / SML00x
  now categorized strictly from HA `device_class` (motion → motion_sensors,
  occupancy → occupancy_sensors). Removed brittle brand-override rules.
  SNZB-06P split into dc-based rules. MQTT generic motion rule routes to
  `motion_sensors` instead of the dead-end `remote_motion_sensors`
  category (the latter is no longer referenced by code). Rules snapshot
  v13 published to rules-service (363 rules total).
- **Removed the motion-fallback guard** in enhanced lighting. Motion and
  occupancy sensors trigger ON independently. Previously, motion was
  gated as a fallback that only fired when all persistent sensors were
  unavailable — that gate hid PIR misses behind unreliable occupancy.
- **New Optimise switch** (`input_boolean.cs_<area>_lighting_optimise`)
  per MIXED area (zones with both a timer source and a persistent
  source). `off` (default) = extinction by configured delay (timer-based).
  `on` = extinction by occupancy state + 2-min sustained-off.
- **Sustained-off as fallback (fix bain stuck-on bug)**: in MIXED zones
  with Optimise=off, if entry occurred via a persistent sensor only (no
  motion/camera/door, so no timer was started), sustained-off triggers
  are still honored — lights extinguish via the slider-configured delay
  applied to the occupancy `for:` window. Without this fallback, MIXED
  zones with persistent-only entry stayed lit indefinitely.
- **Unified delay slider semantic**: `cs_<area>_lighting_delay` (and its
  per-period variants) is now visible in *every* zone with an extinction
  source. The slider drives both the timer duration (timer-source zones)
  and the sustained-off `for:` duration (persistent-source zones), via a
  templated state trigger. Previously, persistent-only zones (atelier,
  cave, garage, exterieur on a real installation) had a hardcoded 2-min extinction
  and the slider was hidden — leading to UI inconsistencies and no way
  to tune the extinction window.
- **Skip off-automation for no-trigger zones** (e.g. `deco`): previously
  generated a dead-code automation with `timer.finished` as the only
  trigger; now skipped entirely.

### Functional model
- `services_manifest.json` regenerated (254 references, +2 vs prior):
  picks up the new `remote_access` service and the
  *"Configurable extinction strategy per MIXED area"* feature, attached
  to both `standard_lighting` and `enhanced_lighting`.
- `cs_functional_model.json` regenerated from the manifest.

## 2.0.40 - 2026-05-11

### Remote access
- Phase 1 deployed on .149: per-system tunnel tokens, frps auth plugin
  in cloud-api, and an in-addon `tunnel_service` spawned from
  `server.py` lifespan so each HA instance is reachable as
  `https://{ha_uuid}.casasmooth.net` without operator intervention.
- Tunnel cutover follow-ups: token rotation hooks, watchdog, retry
  back-off, and clean shutdown sequencing.
- `cs_administration` dashboard now surfaces the read-only tunnel URL
  for the current system so support can copy-paste it without going
  through the cloud portal.

### Media
- MA player detection rewritten: instead of pattern-matching `mass_*`
  in the entity_id, the dashboard reads the HA entity_registry and
  picks players whose integration `platform == music_assistant`. Fixes
  Now Playing on installs where the user renamed the MA player or where
  `cs_rules` has no `music_assistant` entry yet.
- Quick Moods (fixed 2×2 buttons) replaced by **dynamic top-10 MA
  playlists** rendered as tap-to-play tiles. Falls back gracefully when
  MA exposes fewer than 10 playlists.
- Media view sections reordered to: Library, Now Playing, Playlists,
  MA, Players, TVs. Settings tiles in the same view follow the same
  order so the configuration UI mirrors the rendered layout.
- Category sections deduplicate `mass_*` players that already appear
  in the dedicated MA section.
- Music Assistant addon is now installed with `boot=auto`, watchdog,
  ingress_panel, and `auto_update=true` so support doesn't have to
  babysit MA upgrades after first provision.
- Persistent HA notification when MA has no exposed player is clearer
  about the one-time `expose_to_ha` step required.

### Fixes
- `camera_process_snapshots` API endpoint crashed with
  `pattern=None` when called without a filename pattern, which had
  silently stalled the snapshot pipeline since 2026-04-18 — files were
  piling up in the cache instead of being processed.
- Daily-time camera filenames now use the `area_id` slug instead of
  the localized `area_name`, matching the convention already used by
  the frequency-based path. Avoids broken paths on French / German
  installs where area names contain accents or spaces.

### Repos / Build
- `endpoint/` (ESP32-S3 4G camera firmware, ESPHome cameras,
  MicroPython sensors) split out to a dedicated
  [`chrohrbach/casasmooth-endpoint`](https://github.com/chrohrbach/casasmooth-endpoint)
  repository. All `casasmooth_endpoint` legacy references dropped from
  this repo (paths, scripts, docs).
- `addon/build/DOCS.md` is now the source of truth for the HA Add-on
  Store description; the workflow mirrors it to
  `casasmooth-addon/casasmooth/DOCS.md`. Content extended with Music
  Assistant integration, voice setup, and dev mode notes.

## 2.0.39 - 2026-05-10

### Added
- Enhanced Media dashboard rework: when `enhanced_media` is in the
  subscription, three new sections appear at the top of the Media
  view. **Now Playing** is a hero `custom:mini-media-player` bound to
  the best available player (preferring `media_player.mass_*`, falling
  back to the first speaker, then any `media_player`). **Quick Moods**
  is a 2×2 grid of tap-to-trigger tiles wired to four
  `input_button.cs_media_mood_{morning,breakfast,dinner,night}`
  helpers (installer wires the actions in HA automations). **Music
  Library** is a markdown intro plus a button that navigates to the
  MA addon panel at `/d5369777_music_assistant`.
- Auto-provisioning step `provision_music` in cs_update (idempotent):
  registers the Music Assistant addon repository with Supervisor,
  installs and starts the MA addon if missing, opens a WebSocket to
  MA and ensures a Filesystem provider points at `/media/music`,
  copies the bundled public-domain demo MP3s into
  `/media/music/casasmooth/`, and posts a persistent HA notification
  when no `media_player.mass_*` exists so the user knows to open the
  MA panel once (which spawns a Browser Player). No-op when
  `enhanced_media` is not subscribed; failures are logged and never
  block the update.
- 5 public-domain demo MP3 files bundled in
  `app/data/demo_media/casasmooth/` (Bach Brandenburg 6, Vivaldi
  Spring, Satie Gymnopédie 1, Mozart Eine kleine Nachtmusik, Chopin
  Klavierwerke; ~55 MB total). All sourced from Internet Archive
  recordings whose composers and performers are in the public domain.
  Companion script `internals/fetch_demo_media.py` resolves
  identifiers via the IA metadata API so a refresh or replacement is
  one command.
- CLI `python3 -m app provision music` runs the MA provisioning
  workflow on demand for support / one-shot scenarios.
- FR / EN / DE / IT / CS translations for the new media keys
  (`ui_now_playing`, `ui_quick_moods`, `ui_music_library`,
  `ui_music_library_intro`, `ui_open_music_library`,
  `ui_mood_*`).

### Changed
- `enhanced_active` no longer requires `media_player.mass_*`; the
  enhanced sections render as soon as the subscription is present,
  with the Now Playing card pointing at a sensible fallback. Avoids
  shipping an empty Media view to enhanced_media subscribers before
  MA has spawned its first Browser Player.
- Quick Moods tiles use `hide_state: true` + `vertical: true` and
  call `input_button.press` explicitly, so the default
  `last_triggered` "Il y a X secondes" noise no longer pollutes the
  dashboard.

### Lighting
- C1–C11 hardening sequence on the lighting evaluator. C1 introduces
  a dedicated `lighting_eval` timer plus a boot reset of orphan
  rank-2 sources. C2 extracts per-scene apply scripts
  (`script.cs_<area>_apply_scene_<s>`) and lets the system path
  bypass the `scene_memo` claim that was breaking loops. C3–C6 move
  the model from a `/30s` polling automation to event-driven
  triggers (TV / illuminance / UCV state changes) gated by the eval
  timer, with a 30 s boot grace. C8 debounces TV state triggers and
  excludes `unavailable` artefacts. C9 simplifies TV triggers to
  `playing` / `on` / `off` / `standby` only. C10 aligns the
  `standard_lighting` TV triggers with C9. C11 adds a mid-sequence
  presence bail in the off automation.
- TV scene logic simplified: presence-driven inline override, UI
  selector reduced to 0–4.
- `enhanced_lighting` now fires on TV state changes (timer-gated) so
  the TV scene applies in motion-only areas like `mansarde`.
- Registry: cast Chromecasts whose name contains `_tv*` are now
  classified as TVs so they correctly trigger TV scenes.

### Performance / Recorder
- Recorder Phase 1 exclusions: high-frequency SCB / cs_power / Bambu
  / Apollo / plug-voltage sensors are now excluded from the recorder.
  Long-term statistics survive (the exclusion is on `state`, not on
  `statistics`). Significant reduction in DB churn and
  `home-assistant_v2.db` growth.
- UCV (`update_current_values`) state-driven refactor: the
  per-area `cs_<area>_update_current_values` automation no longer
  fires on a `time_pattern` of `/1`; it now uses
  state / time / template triggers. Cuts ~73 k UCV fires/day across
  25 areas while propagating period and parameter changes
  instantly.

### Rules & Detection
- IKEA + Hue motion matching consolidated across Matter / ZHA /
  Z2M. The classifier now keys on manufacturer rather than model,
  which covers truncated Matter names (`MYGGSPRAY`, `VALLHORN`),
  Z2M part-number variants, and the DIRIGERA empty-model edge case.
- Frigate restart alerts are now forwarded to `info@`.
- Quality-gate noise from `notifications.get_secret('guid')` is
  silenced via `log_missing=False`.

### Cloud / Infrastructure
- Cloud API endpoints migrated to `api.casasmooth.net` (Phase 5).
- Heartbeat metadata now reads the version from the `VERSION` file
  rather than a hard-coded constant. `OPENROUTER_CHAT_MODEL`
  switched to `deepseek` (the previously configured `nemotron:free`
  model became unreliable).
- Security: hard-coded GitHub tokens removed from the source tree;
  legacy `Dockerfile` retired (only `addon/build/Dockerfile.production`
  remains).
- `cs_secrets.yaml` master no longer tracked in git (was committed
  in error in an earlier commit; history retains the file but no
  new commits will include it).

### API
- Public `/api/website/catalog.csv` endpoint plus internal project
  quote tooling under `internals/`.

### Docs
- OBD telemetry bridge spec v2 added; `OBDLink CX` is the new
  reference adapter.

## 2.0.38 - 2026-05-05

### Added
- Standalone `cs_lighting` dashboard, gated on the `enhanced_lighting`
  subscription, visible in the sidebar for all users. One section per
  area: 3-column lights grid with `more-info` panel on tile body click
  (brightness/color), 6×2 scenes grid with 100% + scenes 1-4 + suspend
  on row 1 and FX scenes 5-9 on row 2 (suspend rendered same size as a
  scene button), and a per-area unavailability banner driven by a real
  `template binary_sensor.cs_<area>_lighting_any_unavailable`. The banner
  card is wrapped in a `condition: state` conditional card so it
  collapses entirely when no fixture is unavailable (HA conditional
  cards do not support `condition: template`, hence the binary sensor
  indirection). Empty grid cells render borderless — no placeholder
  markdown — matching the cs_home look.
- Multi-provider LLM gateway in `app/utils/llm.py`: Infomaniak (Swiss
  data residency) primary for bulk text purposes (chat, translate,
  recommendations, blog, catalog, rules, features); OpenRouter fallback
  for tool-calling-heavy purposes (conversation) and premium narrative
  (ui_docs via Claude Sonnet) and vision (Gemini Flash). Per-provider
  circuit breaker, per-purpose provider chains, env-var overrides.

## 2.0.37 - 2026-05-04

### Added
- Registry orphan cleanup: new `OrphanCleanupManager` detects helper /
  automation / script entities that previous releases generated but
  the current generation no longer emits, and removes them via the HA
  WebSocket API (`config/entity_registry/remove`). All deletions are
  audit-logged to `logs/cs_orphan_cleanup.jsonl`. Safety rails: only
  `cs_*`-prefixed entries, skips user-disabled / hidden entries,
  refuses to flag a domain whose generation YAML is missing or
  smaller than 1 KiB, hard cap on deletions per run. Exposed as
  `python3 -m app cleanup orphans [--apply] [--list] [--domain X]
  [--max-deletions N] [--yes]` for manual runs, and wired into
  `cs update` as a final step before restart with a per-cycle cap of
  2000 so a large backlog drains gradually. Validated on a long-lived
  production install: 13 146 stale entries removed, 0 errors.
- Power outlets surface as a dedicated section in each area view on
  the Home dashboard.
- New `cs_<area>_vacuum_resume_automation` resumes any vacuum stuck
  in `paused` state for 10 minutes (manual pause, recoverable error).
  The presence-triggered send-home automation now skips when any
  vacuum is already paused, leaving recovery to the resume automation.

### Changed
- Energy dashboard renders even when only one individual consumer is
  configured (previously fell back to the empty-state). Every section
  is now gated on its actual prerequisites — Date / Distribution /
  Sources table / Indicators / Details / Sources tiles only render
  when their backing PV / grid / battery / consumption sensors exist
  — so the view never shows an empty HA Energy built-in card. The
  redundant Consumers / Consumers history / Devices sections
  wrapping HA's `energy-devices-graph` were dropped (they duplicated
  the rule-based Consumers section that was already gated correctly).
- Lighting 100% / 50% / Auto buttons (and their backing automations)
  are now generated for any area with at least one lighting entity,
  not just multi-light areas. Keeps the UI row layout consistent
  and removes the "missing button" surprise on small areas.
- Enhanced lighting / heating / vacuum automations now recognize the
  `presence_sensors` registry category (typically mmWave /
  `device_class=presence`) as persistent presence alongside
  occupancy: included in the OR-conditions, in the periodic
  `time_pattern` re-evaluation, and in the 2-minute sustained-off
  trigger of the lighting-off automation. Motion sensors stay
  edge-based and remain a fallback when all persistent sensors are
  unavailable / unknown.

### Removed
- Dead, unsafe code in `cs_registry.py` that wrote directly to
  `/config/.storage/core.entity_registry`
  (`enable_entities` / `unhide_entities` / `_save_entity_registry`).
  These had zero call sites and would have raced HA's in-memory
  cache. The safe equivalents in `HassApi` (which go through
  `config/entity_registry/update`) are unaffected.

## 2.0.36 - 2026-05-03

### Added
- Booking SPA: shared `BookingCalendar` picker — 30-min calendar grid
  (days × times), multi-slot selection with `+` / `−` buttons, an
  orange selection bar that spans the actual booked duration, an
  `Ajouter le prochain créneau` shortcut, and a `Réserver maintenant`
  shortcut on the zone QR landing when the zone is currently free.
- Picker filter strip: `À partir du` date stepper and `Pas avant` time
  stepper (custom 24h widgets — "Mai 5" / "08:00" — so the rendering
  is locale-agnostic), weekday chips (`Tous / LU…DI`), Précédent /
  Suivant. Cells outside the filter are dimmed at 35 % opacity.
  `+ 1 semaine` extends the horizon by 7 days, repeatable.
- QR codes auto-generated by `cs_update` step 8 for every bookable
  zone (`cs_zone_<area>.png`) **and** every energy consumer in
  `cs_energy_consumers.json` (`cs_power_<entity>.png`). Files land
  in `/media/casasmooth/qrcodes/` so they appear in HA's Media
  Browser. All URLs use the bare UUID — host
  (`<uuid>.casasmooth.net`) and `?guid=` query parameter agree.

### Changed
- `cs_config._load_guid` strips the legacy `csuuid-` prefix at load
  time. `cfg.guid` is now the bare 36-char UUID everywhere; the
  cloud already accepts both forms.
- Booking session cookie is `Secure=True` when the request was HTTPS
  (frps adds `X-Forwarded-Proto`). Was always False, which some
  Android Chromium configs silently dropped on follow-up POSTs.
- Search view simplified — its tag chip + zone selector live in the
  parent, while date / time / weekday filters live inside the shared
  picker. The calendar time axis spans the union of matching zones'
  windows so columns stay stable when the user flips between zones.

### Fixed
- `POST /api/booking/bookings` returned 500 with
  `TypeError: can't compare offset-naive and offset-aware datetimes`.
  Pydantic v2 parses `…Z` ISO strings as timezone-aware; the route
  now normalizes to naive UTC via `_naive_utc()` before any comparison
  against `datetime.utcnow()`.
- Multi-slot reservation: Précédent / Suivant no longer wipe the list
  of pre-selections — they navigate only the latest slot and treat
  earlier ones as occupied. A click inside an already-selected range
  no longer removes the selection (use the row's `−` button). Changing
  the duration drops any selection that, post-change, would overlap
  an earlier one (insertion order wins).

## 2.0.35 - 2026-05-02

### Fixed
- Power router (`/api/power/*`) failed to mount on 2.0.34 because the
  addon image lacked `jinja2` (FastAPI's `Jinja2Templates` raised on
  import). Now baked alongside `sqlalchemy` in `Dockerfile.production`.
- Booking SPA built `https://...:28100/api/booking` for production —
  port 28100 is not exposed publicly via the casasmooth tunnel, so all
  fetches failed with "failed to fetch" once the user clicked Identify.
  Same-origin path on `*.casasmooth.net`, explicit `:28100` only on LAN
  direct.
- Booking magic-link emails now point at `/local/booking/index.html#/...`
  (HA blocks `/local/<dir>/` directory listings with 403, but serves
  named files).
- Booking magic-link email is now an HTML message with a clickable button
  (was plain text).

### Added
- Booking SPA logo (32px header) imported as a Vite asset.
- Booking SPA + Power templates pick up the canonical mobile theme tokens
  (`--surface`, `--on-surface`, `--card-background`, `--primary`, ...).
- nginx wildcard server caches hashed `/local/{mobile,booking}/assets/*`
  for 30 days — first hit goes through frps, subsequent hits served from
  the Azure VM (visible via `X-Cache-Status: HIT` header).

## 2.0.34 - 2026-05-02

### Fixed
- Addon boot was tripping the HA watchdog on slow / failing OpenRouter calls
  during help-page narrative generation, restart-looping the addon. `run.sh`
  now invokes `cs_update --skip-llm` at boot — the same outputs are filled in
  by the in-process background task in `app/api/server.py::_ui_docs_loop`
  once the API server is listening, so first-boot is fast and LLM work
  lands a few minutes later without blocking. (See
  `feedback_addon_boot_watchdog.md`.)

### Added
- `python3 -m app.commands.cs_update --skip-llm` direct flag (mirrors the
  `python3 -m app update --skip-llm` exposed in `cs_main.py`). Both gate the
  same three LLM steps in `cs_generator.run`: recommendations, context docs,
  and help page.
- `sqlalchemy>=2.0` baked into the addon image so the booking + power
  routers in `app/api/` import successfully and mount on `/api/booking/*`
  and `/api/power/*`.

## 2.0.33 - 2026-05-01

### Added
- Per-area `input_select.cs_<area>_lighting_source` and a 30-second
  `timer.cs_<area>_lighting_grace` per zone, forming a unified state
  machine for "who currently drives the lights in this area". Every
  lighting automation now declares its priority via the canonical
  table in `app/core/lighting_arbiter.py` (auto < manual < onoff =
  scene_memo < welcome < tv < scene_script < general < playback <
  fallback) and refuses to act when a higher-rank source already
  holds control.
- `general` mode wired into the existing all-on / all-off / smart-toggle
  buttons. Claims source on every area-with-lights for the duration of
  the action, then releases — blocked when any area is in playback or
  fallback.
- `fallback` kill switch: a global hourly automation that turns off any
  light that has been on longer than the new
  `input_number.cs_lighting_fallback_hours` slider (0 = disabled,
  default 0). Source claim isolates the kill from any active
  automation; runs in `parallel` so an unreachable device cannot
  strand the source.
- Scene 5-10 buttons now toggle: a second press of the same scene
  button stops the running animation; pressing a different 5-10 scene
  during an animation cleanly switches scripts. The dashboard button
  highlights while its script is running.

### Changed
- Standard / enhanced lighting automations now gate on
  `lighting_source == auto`. The old `lighting_timer == active` check
  is preserved alongside; the source check is what enforces the 30-s
  grace after a manual action.
- Scenes 5-10 are now framed as "scripted scenes" and the per-area
  scene 10 (formerly "Cercle de teinte") is repurposed as the
  circadian rhythm script — same 2700-6500 K / 30-100 % curve as the
  retired `auto_daylight_enabled` toggle, but driven by the regular
  scene-row UI instead of a standalone button.
- Welcome lighting and TV-scene-on now claim source so user actions
  cannot interrupt them silently. Welcome releases on its
  `lighting_timer` expiry; TV-scene-off releases when all media
  players become inactive.
- Playback mode toggles `source` on every area-with-lights — the
  whole house follows the global toggle in lockstep.
- Animation start (scene 5-10): the area's lights, bulbs, and
  wall-switches are always turned off before the script runs, even
  when transitioning between scenes. Fixes lit bulbs / switches that
  used to "leak through" an animation if they were on at start.
- Animation end (scene 5-10): RGB lights are reset to 3000 K at low
  brightness, then every area light is turned off. Lights no longer
  stay on in the script's last-frame color when an animation finishes.
  The dashboard "robot" toggle is restored to its pre-animation state
  (the per-scene cleanup already did this; the new safety net handles
  it too, important when `exceptions_enabled` is on and the per-scene
  cleanup is gated out).

### Fixed
- Per-day weekday exception schedule (`s5:07:01-07:04`, etc.) on
  enhanced-only-with-presence zones with no motion in the window. The
  override used to set `lighting_scene` and stop there; now it also
  presses the matching restore_scene button so the scene is actually
  applied without depending on a periodic auto tick.
- Animation script while-loop now also checks `lighting_source ==
  scene_script`, so a higher-priority mode (playback / general /
  fallback) supplanting mid-animation makes the script exit at the
  next iteration instead of running silently in the background.
- Scene 10 (circadian) iteration uses `wait_template` with a 60-s
  timeout instead of a flat `delay: 60s` — the script exits within
  ~100 ms of being supplanted instead of having to wait for the next
  natural cycle.
- `homeassistant.turn_off` calls in the new white+off cleanup,
  in the global force-off, and in fallback kill no longer pass a
  `transition` argument: the generic multi-domain service rejects
  the key when the target list mixes lights with switches, which was
  silently aborting the cleanup mid-sequence and leaving
  `lighting_source` stuck at `scene_script`.
- 50 % button now actually sets brightness to 50 %. The previous
  `light.turn_on` carried no `data` block, so dimmable lights came on
  at HA's default brightness (typically 100 % or last value). Same
  idempotent guard pattern as the 100 % button.
- 100 % automations are now generated only for areas with multiple
  lights (matching the dashboard button which is conditional on
  `has_multiple_lights`). Previously the automation was built
  unconditionally — single-light areas had a dead-code automation
  whose trigger entity did not exist.
- Stale `cs_<area>_auto_daylight_enabled` entity reference removed
  from standard / enhanced automations and from the `cs_home.py`
  generator. The entity is no longer produced; orphan entries in
  `.storage/core.entity_registry` are cosmetic and can be cleaned up
  via the HA UI.

## 2.0.32 - 2026-04-27

### Fixed
- Area lighting auto-off no longer skips when a user scene (1-4) is
  active. The off automation's "scene guard" now only blocks when an
  animation script (scenes 5-10) is running — animations control the
  lights and must not be interrupted, but static user scenes are
  meant to be released by the lighting timer like any other state.
  Previously, any non-zero scene blocked the timer.finished handler,
  so a single motion event during a period whose default scene was
  1-4 would leave lights on indefinitely.
- TV-scene-off no longer leaves the room dark for several seconds
  when a media player stops:
  - the unconditional `homeassistant.turn_off` of all area lights
    has been removed (it was the source of the visible blackout);
  - the area's animation scripts (5-10) are now stopped explicitly
    before handing control back to the regular lighting automation;
  - `cs_<area>_lighting_scene` is force-refreshed from the period
    config via an immediate trigger of
    `cs_parameters_<area>_update_current_values`, so the next
    enhanced/standard trigger sees the right scene number instead
    of the placeholder `0` and presses the matching restore_scene
    button (otherwise the room could stay dark up to 60 s, until
    the next minute-cycle of update_current_values);
  - the inter-step delay shrinks from 1 s to 200 ms;
  - the fallback branch (robot was off before TV) fades the lights
    out with a 1 s transition instead of an abrupt cut.

## 2.0.31 - 2026-04-21

### Fixed
- Boot no longer stalls on LLM regeneration when the instance UI bundle
  cache is invalidated by an upgrade. The `Instance UI docs` step has
  been moved out of the `cs_update` critical path into a background
  task that runs 60 s after the API server starts listening (and daily
  at 03:15 thereafter). First boot is now fast; the localised user
  guides land a few minutes later without tripping the HA watchdog and
  without triggering the restart loop that was observed on 2.0.30.

---

## 2.0.30 - 2026-04-20

### Added
- `product_shops` catalog (admin CRUD + per-language filtering) with
  URL templates using the `{product_name}` placeholder, replacing the
  per-product `specifications.online_shops` free-form JSON.
- Dedicated `crm-portal` container for `/crm/*` admin routes — the
  public website container no longer serves admin UI.
- `linked_systems` is now included in the `/api/auth/login`,
  `/api/auth/refresh`, `/api/auth/me` and MFA-verify responses so the
  tarifs page renders linked systems + plans immediately after login
  instead of depending on a subsequent `/api/auth/me` refresh.
- Stripe cancellation on system deletion: admin-initiated system
  removal now cancels every attached Stripe subscription / addon item
  before dropping the DB rows. No more orphan Stripe subscriptions
  after a cleanup.
- Support for `dev_mount` addon option to run from an editable
  `/config/casasmooth/app` tree instead of the baked image.

### Fixed
- Subscription entitlement cache consolidated into a single
  `locals/cs_services.json` file (was split between
  `locals/cs_services.txt` and `cache/services.json`, which drifted
  out of sync — the plain-text file was only ever written on first
  install, never refreshed). Legacy `cs_services.txt` is migrated
  transparently on first read and then removed.
- `/api/services` and `/api/admin/systems` now include trial-mode
  subscriptions (`status IN ('active','trial')`). Trial plans were
  previously invisible to the services resolver and to the admin
  systems list — a Premium trial system rendered as "No Plan" and
  received an empty service list.
- Fallback path when no subscription is active no longer tries to look
  up a non-existent `standard_base` *subscription* row; it now resolves
  to the Freemium plan (+ `standard_base` service) as intended.
- Ownership transfer flow rejects placeholder / malformed new-owner
  emails (e.g. the literal string `"unknown"` that some HA instances
  report before the owner sets a real address). No transfer row or
  email is created when the heartbeat reports a value without `@` and
  a dotted domain.
- System deletion cascade now covers `ClientServiceAddon` rows and the
  FK-cascaded tables (heartbeats, backups, bridging config).
- Ops-portal `DELETE /systems/<guid>/assignments/<kind>/<int:aid>`
  route no longer 500s — the function signature was missing the `aid`
  kwarg.
- Ops-portal Plans & Services editor: the "Actuellement actif" list no
  longer overlaps the editor below; items are now rendered as flex
  cards with a visible separator above "Modifier l'assignation".
  "revoke" renamed to "Révoquer".
- Assignment recap email is skipped (with a warning) when the system
  has a placeholder email, instead of letting Graph/Resend reject the
  whole batch.

### Infrastructure
- Nginx routes `/api/ownership/*` to cloud-api on all three server
  blocks (HTTP, HTTPS-FQDN, HTTPS-casasmooth.com) so claim / revert
  email links actually reach the FastAPI router. Previously
  `https://casasmooth.com/api/ownership/transfer/revert?token=…` fell
  through to the website container and returned a Flask 404.
- Cloud-api + operations-portal rebuilt with the above changes.

---

## 2.0.21 - 2026-04-17

### Changed
- Sync published add-on metadata with casasmooth production image version 2.0.21

---

## 2.0.20 - 2026-04-17

### Added
- Remote access token (`cs_remote_token`) for opt-in remote management — written to `cs_states.yaml` via startup automation
- Nightly housekeeping job (scheduled maintenance)
- Admin energy billing email button on the Rapports dashboard
- Air quality and weather report emails

### Changed
- Manual update flow now uses `--full-restart` by default
- Rapports dashboard: limited to 3 columns
- Sync published add-on metadata with casasmooth production image version 2.0.20

---

## 2.0.18 - 2026-04-09

### Changed
- Sync published add-on metadata with casasmooth production image version 2.0.18
- Align mirrored add-on boot script comments with the production source repository

---

## 2.0.13 – 2026-03-25

### Added
- Pre-install 6 additional HA add-ons on first boot: Whisper STT, Piper TTS, File Editor, Samba, DuckDNS, Let's Encrypt
- Add-on icons (icon.png, logo.png) for HA add-on store

### Changed
- Documentation updated to reflect all 8 pre-installed add-ons
- Boot sequence comments updated

---

## 2.0.3 – 2026-02-24

### Fixed
- `is_hass_environment()` now detects addon container via `SUPERVISOR_TOKEN` (not just `ha` CLI presence) – Home Assistant core restart was silently skipped on every update cycle
- `restart_hass_core()` uses Supervisor REST API when running inside container (`ha core restart` not available)
- Whisper and Piper addon install/status checks use Supervisor REST API inside container (same root cause)
- Dev addon installation step removed from production update flow
- `cs-cameras` dashboard no longer generated when no cameras or Frigate cameras are configured

---

## 2.0.2 – 2026-02-24

### Security / Cleanup
- `texts/` (multilingual email/notification templates) now stays inside the container image – no longer copied to host filesystem
- Removed dead `embedded_data.py` module (760 lines of unused gzip+base64 blobs)
- Removed dead `templates/` folder – was never read by Python or bash at runtime

### Fixed
- `cs_services.txt` (subscription entitlement) moved from `cache/` → `locals/` so it survives cache clears and is clearly identified as persistent state
- Legacy bash updater (`cs_update_casasmooth.sh`) aligned with Python paths for `cs_services.txt`
- Boot sequence comment corrected (removed stale reference to removed step)

---

## 2.0.1 – 2026-02-20

### Security
- `app/data/` directory (rules, configuration, translations, secrets template) stays entirely inside the container image – never exposed to host filesystem
- `CS_APP_DATA` env var points to `/opt/casasmooth/app/data` inside the image
- Only `cs_logo.png` deployed from `images/` – personal/test images removed from the image

### Fixed
- `cs_update` now runs at boot with `--log --verbose` before API and MCP servers start
- `templates/` removed from host sync list (bash-only legacy, Python never reads it)

---

## 2.0.0 – Initial addon release

- First production HA addon release
- Python-based architecture replacing legacy bash updater
- MCP server on port 8003
- API server with SUPERVISOR_TOKEN authentication
