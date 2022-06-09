;;L'extension «nw» doit savoir exactement quels ensembles d'agents sont les nœuds et quels sont
;;les liens. Nous avons créé un ensemble de nœuds et un ensemble d'arêtes et nous travaillerons avec eux,pour créer un graphe
extensions [ nw ]

;;variable globale accesible pour tout les agents
globals
[
    Nb-infecté-initialement
    maximum-NB-Agent-infectieux           ;; Le nombre maximum d'individus infectieux à une tique de simulation.
   tick-au-maxNB-infectieux    ;; La (première) tick lorsque le nombre maximum d'individus infectieux est atteint.
   vecteur-nombre-infectieux     ;; Vecteur du nombre d'individus infectieux à chaque tique de simulation.

  incubation-alpha             ;; Paramètre alpha de la distribution gamma utilisé dans le calcul du temps d'incubation.
  incubation-lambda            ;; Paramètre Lambda de la distribution gamma utilisé dans le calcul du temps d'incubation.

  infection-alpha             ;;Paramètre Alpha  pour la distribution gamma utilisée dans le calcul du temps infectieux.
  infection-lambda            ;;Paramètre Lambda  pour la distribution gamma utilisée dans le calcul du temps infectieux.

]
;;variables turtules pour chaque agents
turtles-own [

  id          ;; id de l'agent
  age         ;; age de l'agent
  sexe        ;;sexe d'agent (1:mal, 2:femelle)
  Niveau_intelectuelle  ;; niveau intellectuelle d'agent(1:primaire,2:moyen,3:secondaire,4:universitaire)
  ville       ;; ville d'agent(dans notre cas nous avons pris un échantillon de la ville sétif)
  passion     ;; passion d'gent(centre d'interet(politique,footballe,la mode, rechrche,santé ect.....)(1:sport,2:cuisne,3:politique,4:santé,5:mode)
  sensible?    ;; Si vrai, l'individu fait partie de la classe sensible.
  contacté?    ;; Si vrai, l'individu fait partie de la classe contacté.
  infecté?      ;; Si vrai, l'individu fait partie de la classe infecté.
  rétabli? ;; Si vrai, l'individu fait partie de la classe rétabli.
  incubation-longueur       ;; Depuis combien de temps l'individu est dans la classe exposée, augmentant de 1 à chaque tick. Ceci est comparé au temps d'incubation, sélectionné à partir d'une distribution gamma.
  durée-d'incubation             ;; La valeur de distribution gamma choisie au hasard pour combien de temps l'individu restera dans la classe exposée.
  longueur-infection        ;; Depuis combien de temps l'individu est dans la classe infectieuse, augmentant de 1 à chaque tique. Ceci est comparé au temps infectieux, sélectionné à partir d'une distribution gamma
  durée_d'infection     ;;La valeur de distribution gamma choisie au hasard pour combien de temps l'individu restera dans la classe infectieuse.
  profile
  centrality
  total-contacts
  Activité
  Nombre_amis
]

directed-link-breed [tests test]
links-own [weight]
;graphml Les outils de dessin de graphiques, comme tous les autres outils traitant des données relationnelles, doivent stocker et échanger des graphiques et des données associées.
;comme dans notre cas nous avons utilisés pour dessiner notre graphe du réseau social.
to Importer-Graphe
  clear-all
 ;;  si vous ne voulez pas être invité à chaque fois:
  ;; laissez le nom de fichier  "/chemin/de/mongraphe.graphml"
  let nomdefichier user-file
  if (nomdefichier != false) [
    nw:load-graphml nomdefichier [
      set infecté? false
      set shape "person"
      set size 2.5
                                 ]
    nw:set-context turtles links
                         ]
end
;**********************************************************************************************************************************************************************************************




to update-layout        ;la mise en oeuvre du notre graphe
  layout-spring turtles links 0.2 .1 1

end

;***********************************************************************************************************************************************************************************************
; centralité sont des mesures censées capturer la notion d'importance dans un graphe, en identifiant les sommets les plus significatifs.
;nous avons utilisé les mesures de centralité pour identifier le sommet le plus influent dans notre graphe.
to calc-centrality     ; la calcule de centrality selon la mesure choisi(pagerank,random,eigenvector-centrality,eigenvector-centrality,closeness-centrality)
  if centrality-measure = "random" [
    ask turtles [set size random 2 + 1]
    stop
  ]
  if centrality-measure = "reset-size" [
    ask turtles [set centrality 1 set size 1]
    stop
  ]
  if centrality-measure = "degree-centrality" [
    ask turtles [set centrality count my-links]
    ask turtles [set size 2 * (normalize centrality min [centrality] of turtles max [centrality] of turtles)]
    stop
  ]
  let the-task (word "set centrality nw:" centrality-measure)
  ask turtles [run the-task]
  ask turtles [set size 5 * (normalize centrality min [centrality] of turtles max [centrality] of turtles)]

end
;reporteur pour normaliser la valeur de centrality
to-report normalize [value le-min le-max]
  set le-min ifelse-value (le-min = 0) [.001] [le-min]
  let normalized (value - le-min) / (le-max - le-min)
  report normalized
end
;;**********************************************************************************************************************************************************************************************
;;Dans notre cas de modélisation on a besoin de probababilité,nous avon utilisé la distribution gamma
;;la distribution gamma ,un type de loi de probabilité de variables aléatoires réelles positives.
;;elle utilisé pour modéliser une grande variété de phénomènes, et tout particulièrement les phénomènes se déroulant au cours du temps.
;;Elle s'applique à une variable positive et non limitée.
;;dans notre cas les parametre de la loi sont la moyenne et l'acart type
to setup-gamma-distributions ;; Le calcul de la moyenne et de l'écart-type (en jours) aux paramètres alpha et lambda requis pour les distributions gamma (en ticks).


  set incubation-alpha (période-moyenne-d'incubation * ticks-par-jour)^ 2 / (écart-type-d'incubation * ticks-par-jour)^ 2
  set incubation-lambda (période-moyenne-d'incubation * ticks-par-jour) / (écart-type-d'incubation * ticks-par-jour)^ 2
  set infection-alpha (période-moyenne-d'infection * ticks-par-jour)^ 2 / (écart-type-d'infection * ticks-par-jour)^ 2
  set infection-lambda (période-moyenne-d'infection * ticks-par-jour) / (écart-type-d'infection * ticks-par-jour)^ 2
end
;;**********************************************************************************************************************************************************************************************

to Infecter-unRandom
 ask  turtle  random 55           ;; L'individu aleatoire  commence comme infectieux. Son temps infectieux est choisi parmi la distribution gamma et la longueur infectieuse fixée à 0.
    [
      set infecté? true
  set contacté? false
  set sensible? false
  set rétabli? false
  set color red
  set size 3
        set   Nb-infecté-initialement  Nb-infecté-initialement + 1
      set durée_d'infection  random-gamma infection-alpha infection-lambda
      set longueur-infection 0
    ]
end
;***********************************************************************************************************************************************************************************************
to attribuer-couleur
  if sensible?
    [ set color white ]
  if contacté?
    [ set color yellow ]
  if infecté?
    [ set color red ]
  if rétabli?
    [ set color lime ]
end
;***********************************************************************************************************************************************************************************************
to setup00
    set  profile  []
    set profile fput passion  profile

end
;;procedure permettre d'initialliser les variables , initialise les ticks
to setup
  clear-all-plots
  setup-gamma-distributions


  ask turtles [
    set infecté? false
     set sensible?  true               ;; Tous les individus sont définis comme sensibles.
    set contacté? false
    set rétabli? false

    set label Label
    set color white
    set size 3
    set vecteur-nombre-infectieux [ 1 ]   ;; Le vecteur  vecteur nombre-infectieux est initialisé.
    attribuer-couleur
    ]
   ask links [
    set thickness 0.2
    set color grey
  ]

  ask turtles [

    setup00

  ]
set Nb-infecté-initialement 0
   reset-ticks
end

;************************************************************************************************************************************************************************************************

to infecte-moi-enpremier
  ifelse count turtles with [  infecté? ] < 10[
    infecte-moi

    show (word "Vous avez dit a "label " La rumeur")
  ]
  [
    user-message "Nous avons déja des épandeurs de rumeur . Démarrez le modèle maintenant."
  ]
end
;;************************************************************************************************************************************************************************************************
to infecte-moi
  set infecté? true
  set contacté? false
  set sensible? false
  set rétabli? false
  set color red
 ; set size 3
end
;;**********************************************************************************************************************************************************************************************
;; infecter par centralité veut dire infecteer le noeud le plus influentes dans un réseau social,ou le sommet le plus signifiacative slon les mesures
to   infecte-par-centrality

  ifelse centrality-measure = "random"
    [ ask one-of turtles with [ not infecté? ]
      [infecte-moi-enpremier
     set   Nb-infecté-initialement  Nb-infecté-initialement + 1
         set durée_d'infection random-gamma infection-alpha infection-lambda]

    ]
    [
      calc-centrality
      ask max-one-of turtles with [ not infecté? and centrality != false] [ centrality ] [
        infecte-moi-enpremier
       set   Nb-infecté-initialement Nb-infecté-initialement + 1
        set durée_d'infection random-gamma infection-alpha infection-lambda
      ]

    ]
end
;;**********************************************************************************************************************************************************************************************
;;permetre de déclencher la simulation
to go

   if all? turtles [ sensible? or rétabli? ]         ;; La simulation se termine lorsqu'aucun individu n'est infecté (contacté ou infectieux).
    [ stop ]
    ; ask turtles[move]

   propager-rumeur

;ask turtles with [ infecté? ] [move]
     ask turtles with [ infecté? ]                 ;; Les personnes infectées peuvent contacter (contaminer) les voisins sensibles. Si des individus infectieux ont été infectieux pour des tiques durée_d'infection, ils se rétabliront.
    [ passer-a-contacté
      passer-a-rétabli ]

  ask turtles with [ contacté? ]                           ;; Si les individus contactés ont été dans la classe contactée pendant  les ticks  de durée d'incubation, ils deviendront infectieux
    [ passer-a-infecté
  ]

  ask turtles
    [ attribuer-couleur
      count-contacts ]


 compute-maximum-infectious

  tick
end
;;*********************************************************************************************************************************************************************************************
;; propage l'information en deux cas si caracteristique on l'information se propage prennant en compte les caractérestique des agents
;;autrement l'information se propage aléatoirement(un agnts infecté vvoisin a un agent sensible l'agents sensible sera contacté,l'agent contacté  aprés un certain temps passe a l'etat infecté puis passe a
;l'atat rétabli dont l'information sera oublié ou la fakenews seera corrigé et l'agent ne la rediffuse plus
to propager-rumeur
  ask turtles with [infecté?]
  [ifelse (caractérestique = true)
 [ ask link-neighbors with [not  rétabli? and individual-similarity self  myself != false]


       [ if  Activité != false and influenceofAgent self != false
        [ devenir-infecté ] ]
    ]
      [ ask link-neighbors with [not  rétabli?]


        [ devenir-infecté ]
  ]]
end





;;**********************************************************************************************************************************************************************************************
;;utiliser en cas d'infection lors de la propagation d'information
to devenir-infecté  ;; turtle procedure
  set infecté? true
  set sensible? false
  set rétabli? false
  set color red
end

;***********************************************************************************************************************************************************************************************
;;passage a l'état contacté aprés une infection par un voisin infecté selon une probabilité (
to passer-a-contacté
 ; let prop 0.5
  ask link-neighbors with [ sensible? ]                              ;; Les personnes sensibles qui entrent en contact avec une personne infectieuse seront infectées avec probabilité de propagation.
    [
      if random-float 100 < Probabilité-propagation  ;and  p > prop
      [
          set sensible? false
          set contacté? true
          set durée-d'incubation    random-gamma incubation-alpha incubation-lambda      ;; Un individu nouvellement exposé sélectionne une durée d'incubation à partir de la distribution gamma et sa longueur d'incubation est fixée à 0.
          set incubation-longueur 0
          set color yellow
      ]
    ]
end
;;**********************************************************************************************************************************************************************************************
;;utiliser lors du passage de l'etat contacté a l'etat infecté
to passer-a-infecté                                                   ;; Lorsqu'un individu infecté a été dans la classe contacté plus longtemps que sa durée d'incubation, il deviendra infectieux.
  set incubation-longueur incubation-longueur + 1
  if incubation-longueur > durée-d'incubation
  [
    set contacté? false
    set infecté? true
    set durée_d'infection random-gamma infection-alpha infection-lambda            ;; Un individu nouvellement infectieux sélectionne une durée_d'infection dans la distribution gamma et sa longueur d'infection est fixée à 0.
  ]
end
;;**********************************************************************************************************************************************************************************************
;; utiliser en cas du pasaage de ll'état infecté a rétabli
to passer-a-rétabli                                                              ;; Lorsqu'un individu infectieux a été dans la classe infectieuse plus longtemps que son temps d'infection, il se rétablira.
  set longueur-infection longueur-infection + 1
  if longueur-infection > durée_d'infection
  [
    set infecté? false
    set rétabli? true
  ]
end
;***********************************************************************************************************************************************************************************************
to compute-maximum-infectious                                                      ;; Un vecteur du nombre d’individus infectieux à chaque tique est stocké. Le maximum et le temps du maximum sont calculés.
  set  vecteur-nombre-infectieux lput count turtles with [infecté?]  vecteur-nombre-infectieux
  set  maximum-NB-Agent-infectieux max  vecteur-nombre-infectieux
  set tick-au-maxNB-infectieux  position  maximum-NB-Agent-infectieux  vecteur-nombre-infectieux
end

  ;;*****************************************************************************************************************************************************************************************


;; pou calculer le nombre d'agents
  to count-contacts
 set total-contacts 0
  set total-contacts total-contacts + count other turtles
end
;;*****************************************************************************************************************************************************************************************
;reporter return true si un agents est influent dans le réseau ou non en fonction de son nombre d'amis ,return false dans le cas contraire.
to-report influenceofAgent  [turtle-1 ]
  let nbr-amis [Nombre_amis]  of turtle-1
  report  ifelse-value (nbr-amis > 500) [true] [false]

end
;;*****************************************************************************************************************************************************************************************

;; un reporter returne  1 si les centres d'intert de deux agent sont similaire donc les agents sont similaire et peuvent partager la meme information,returne 0 si il nya pas une similarité
to-report individual-similarity [turtle-1 turtle-2]
 let ll1 [ profile] of turtle-1
  let ll2 [ profile] of turtle-2
  let ll3 ( map = ll2 ll1 )
 ; show ll3
 show reduce [ [occurrence-count next-item] ->
    ifelse-value (next-item) [occurrence-count + 1] [occurrence-count] ] (fput 0 ll3)
  report ll3
end
@#$#@#$#@
GRAPHICS-WINDOW
329
15
870
557
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
194
18
319
51
NIL
Importer-Graphe
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
7
16
157
50
1* Importer notre Réseau social
14
14.0
1

TEXTBOX
9
66
333
109
****************************************\n
14
0.0
1

BUTTON
194
83
317
116
MàJ_Graphe
update-layout\n\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
11
90
161
124
2* Mise en oeuvre du Réseau social
14
14.0
1

CHOOSER
152
157
325
202
centrality-measure
centrality-measure
"reset-size" "random" "degree-centrality" "page-rank" "betweenness-centrality " "eigenvector-centrality" "closeness-centrality"
3

BUTTON
152
206
326
239
NIL
calc-centrality
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
3
137
328
171
****************************************
14
0.0
1

TEXTBOX
1
160
151
194
3*Calculer la centralitée des Agents
14
14.0
1

SLIDER
110
411
288
444
ticks-par-jour
ticks-par-jour
1
24
24.0
1
1
ticks / jour
HORIZONTAL

SLIDER
91
295
303
328
écart-type-d'incubation
écart-type-d'incubation
0.2
7
1.6
0.2
1
jours
HORIZONTAL

SLIDER
91
333
303
366
période-moyenne-d'infection
période-moyenne-d'infection
0.5
7
5.5
0.5
1
jours
HORIZONTAL

SLIDER
93
371
304
404
écart-type-d'infection
écart-type-d'infection
0.5
7
4.5
0.5
1
jours
HORIZONTAL

BUTTON
151
445
230
478
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1128
17
1277
50
infecte-par-centrality
infecte-par-centrality
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1122
94
1315
127
Probabilité-propagation
Probabilité-propagation
0
100
46.0
1
1
%
HORIZONTAL

TEXTBOX
1
238
330
256
****************************************
14
0.0
1

TEXTBOX
4
255
154
273
4*Setup
14
14.0
1

TEXTBOX
899
58
1049
76
5*GO
14
14.0
1

TEXTBOX
904
226
1314
244
**************************************************
15
0.0
1

TEXTBOX
1127
469
1277
487
NIL
11
0.0
1

TEXTBOX
897
242
1047
260
6*Résultat
14
14.0
1

MONITOR
894
168
969
221
Sensible?
count turtles with [sensible?]
12
1
13

MONITOR
969
168
1047
221
Contacté?
count turtles with [contacté?]
12
1
13

MONITOR
1052
168
1117
221
Infecté?
count turtles with [infecté?]
12
1
13

MONITOR
1121
168
1186
221
Rétabli?
count turtles with [rétabli?]
12
1
13

MONITOR
1188
167
1321
220
ProfondeurInfection
maximum-NB-Agent-infectieux
12
1
13

PLOT
880
266
1220
447
 Graphe de Simulation des Agent
temps(tick)
nombreAgents
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Sensible?" 1.0 0 -16777216 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ sensible? ]"
"Contacté?" 1.0 0 -1184463 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ contacté? ]"
"Infecté?" 1.0 0 -2674135 true "" "plotxy (ticks / ticks-par-jour) count turtles with [infecté? ]"
"Rétabli?" 1.0 0 -13840069 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ rétabli? ]"
"Total" 1.0 0 -14730904 true "" "plotxy (ticks / ticks-par-jour) count turtles"

BUTTON
1001
48
1064
81
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
984
17
1124
50
NIL
Infecter-unRandom
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1142
127
1284
160
caractérestique
caractérestique
0
1
-1000

MONITOR
1135
50
1273
95
NIL
Nb-infecté-initialement
17
1
11

SLIDER
91
260
303
293
période-moyenne-d'incubation
période-moyenne-d'incubation
0.2
7.0
1.4
0.2
1
jours
HORIZONTAL

PLOT
1221
265
1527
448
Courbe des Agents Sensibles
temps(tick)
nombreAgents
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Sensible?" 1.0 0 -16777216 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ sensible? ]"
"Total" 1.0 0 -14730904 true "" "plotxy (ticks / ticks-par-jour) count turtles"

PLOT
998
451
1340
631
Courbe des Agents Infectés
temps(tick)
nombreAgents
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Infecté?" 1.0 0 -2674135 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ infecté? ]"
"Total" 1.0 0 -14730904 true "" "plotxy (ticks / ticks-par-jour) count turtles "

PLOT
1529
265
1831
448
Courbe des Agents Contactés
temps(tick)
nombreAgents
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Contacté?" 1.0 0 -1184463 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ contacté? ]"
"Total" 1.0 0 -14730904 true "" "plotxy (ticks / ticks-par-jour) count turtles "

PLOT
1341
450
1650
631
Courbe des Agents Rétablis
temps(tick)
nombreAgents
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Rétabli?" 1.0 0 -13840069 true "" "plotxy (ticks / ticks-par-jour) count turtles with [ rétabli? ]"
"Total" 1.0 0 -14730904 true "" "plotxy (ticks / ticks-par-jour) count turtles "

MONITOR
949
98
1104
143
tick-au-maxNB-infectieux 
tick-au-maxNB-infectieux
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
