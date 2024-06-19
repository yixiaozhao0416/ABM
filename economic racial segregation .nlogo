globals [
  percent-unhappy  ;; what percent of the turtles are unhappy?
  average-color-similarity;; on the average, what percent of a turtle's neighbors have same color
  average-income-similarity
]

turtles-own [
  happy?              ;; for each turtle, indicates whether at least %-similar-wanted percent of
  income              ;; income of the turtle
  color-similarity
  income-similarity
]

patches-own [
  consumption-level   ;; consumption level of the environment
]

to setup
  clear-all
  set-default-shape turtles "person"
  setup-patches
  setup-turtles-color
  setup-turtles
  update-turtles
  update-globals
  adjust-consumption-levels
  reset-ticks
end


to setup-patches
  ;; Set random consumption level for each patch in a stepwise manner

  let step-size (max-consumption-level - min-consumption-level) / num-steps  ;;
  ask patches [
    let step random 5  ;;
    set consumption-level (min-consumption-level + step * step-size)  ;;
    set pcolor scale-color blue consumption-level min-consumption-level max-consumption-level
  ]

  ;; Adjust layout based on similarity-threshold
  ask patches [
    let similar-patches patches in-radius 10 with [abs(consumption-level - [consumption-level] of myself) < similarity-threshold]
    let average-similarity mean [consumption-level] of similar-patches

    ;; Adjust the layout based on average-similarity
    ifelse average-similarity > consumption-level [
      ;; If average-similarity is higher, disperse the consumption-level
      set consumption-level consumption-level - (average-similarity - consumption-level)
    ] [
      ;; If average-similarity is lower, concentrate the consumption-level
      set consumption-level consumption-level + (consumption-level - average-similarity)
    ]
    set pcolor scale-color blue consumption-level min-consumption-level max-consumption-level
  ]
end





to setup-turtles-color
  ;; Create turtles with random income and initial happiness
  let total-proportion red-proportion + green-proportion + yellow-proportion + brown-proportion + pink-proportion
   ;; Calculate number of turtles for each color
  let num-red-turtles round (red-proportion / total-proportion * numbers)
  let num-green-turtles round (green-proportion / total-proportion * numbers)
  let num-yellow-turtles round (yellow-proportion / total-proportion * numbers)
  let num-brown-turtles round (brown-proportion / total-proportion * numbers)
  let num-pink-turtles round (pink-proportion / total-proportion * numbers)
 ;; Create turtles with random income and initial happiness
  create-turtles num-red-turtles [
    set color red
    set-income-range
  ]
  create-turtles num-green-turtles [
    set color green
    set-income-range
  ]
  create-turtles num-yellow-turtles [
    set color yellow
    set-income-range
  ]
  create-turtles num-brown-turtles [
    set color brown
    set-income-range
  ]
  create-turtles num-pink-turtles [
    set color pink
    set-income-range

  ]
  end

to set-income-range
  ;; Set income range for each turtle based on their color
  ifelse color = red [
    set income random-float (red-max-income-level - red-min-income-level) + red-min-income-level
  ] [
    ifelse color = green [
      set income random-float (green-max-income-level - green-min-income-level) + green-min-income-level
    ] [
      ifelse color = yellow [
        set income random-float (yellow-max-income-level - yellow-min-income-level) + yellow-min-income-level
      ] [
        ifelse color = brown [
          set income random-float (brown-max-income-level - brown-min-income-level) + brown-min-income-level
        ] [
          ;; For pink color turtles
          set income random-float (pink-max-income-level - pink-min-income-level) + pink-min-income-level
        ]
      ]
    ]
  ]
end


to setup-turtles
   ask turtles [
    let current-patch patch-here
    let current-consumption [consumption-level] of current-patch
    let double-consumption 3 * current-consumption
    set happy? income >= current-consumption and income < double-consumption
    move-to one-of patches
  ]
  end
 ;; Adjust consumption level of the patch based on turtle's income
;; Adjust consumption level of each patch based on nearby turtles' income
to adjust-consumption-levels
  ask patches [
    if any? turtles-here [
      let average-income mean [income] of turtles-here
      let adjustment-factor 0.1  ;; You can adjust this factor as needed
      let income-difference average-income - consumption-level
      set consumption-level consumption-level + (income-difference * adjustment-factor)
      ;; Ensure consumption level does not exceed maximum or minimum
      if consumption-level > max-consumption-level [
        set consumption-level max-consumption-level
      ]
      if consumption-level < min-consumption-level [
        set consumption-level min-consumption-level
      ]
      set pcolor scale-color blue consumption-level min-consumption-level max-consumption-level
    ]
  ]

end



to go
  tick
  if all? turtles [happy?] [ stop ]
  move-unhappy-turtles
  update-turtles
  update-globals
  adjust-consumption-levels
end

to move-unhappy-turtles
  ask turtles with [not happy?] [
    find-new-spot
  ]
end

to find-new-spot
  move-to one-of patches with [not any? turtles-here]
end

to update-turtles
  ask turtles [
     ifelse  any? turtles-on neighbors [let similar-neighbors count other turtles in-radius 1 with [color = [color] of myself]
    let total-neighbors count turtles-on neighbors
    ifelse total-neighbors > 0 [
      set color-similarity similar-neighbors / total-neighbors  ;;
    ] [
      set color-similarity 0  ;;
    ]]
    [
      set income-similarity 0  ;;
    ]
     ifelse  any? turtles-on neighbors [let neighbor-income-mean mean [income] of turtles-on neighbors
     let similar-income-neighbors count turtles-on neighbors with [abs(neighbor-income-mean - [income] of myself) < 20]
          let total-neighbors count turtles-on neighbors
    ifelse total-neighbors > 0 [
      set income-similarity similar-income-neighbors / total-neighbors  ;;
    ] [
      set income-similarity 0  ;;
    ]][
      set income-similarity 0  ;;
    ]
     let current-consumption [consumption-level] of patch-here
    let double-consumption 3 * current-consumption

    set happy? income >= current-consumption and income < double-consumption
  ]
end



to update-globals
  let total-similar-neighbors sum [color-similarity]  of turtles
  set average-color-similarity total-similar-neighbors / count turtles
  let total-similar-income-neighbors sum [income-similarity] of turtles
  set average-income-similarity ifelse-value (count turtles > 0) [total-similar-income-neighbors / count turtles] [0]
  set percent-unhappy (count turtles with [not happy?]) / (count turtles) * 100
end
@#$#@#$#@
GRAPHICS-WINDOW
221
10
658
448
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
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
25
23
95
56
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
109
24
172
57
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
10
99
210
132
min-consumption-level
min-consumption-level
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
8
132
211
165
max-consumption-level
max-consumption-level
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
7
251
179
284
numbers
numbers
0
1000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
7
284
179
317
red-proportion
red-proportion
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
6
317
178
350
green-proportion
green-proportion
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
6
349
178
382
yellow-proportion
yellow-proportion
0
1
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
6
382
178
415
brown-proportion
brown-proportion
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
6
414
178
447
pink-proportion
pink-proportion
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
669
35
859
68
red-min-income-level
red-min-income-level
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
863
67
1063
100
pink-max-income-level
pink-max-income-level
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
668
67
864
100
pink-min-income-level
pink-min-income-level
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
877
100
1089
133
brown-max-income-level
brown-max-income-level
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
668
99
877
132
brown-min-income-level
brown-min-income-level
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
874
131
1085
164
yellow-max-income-level
yellow-max-income-level
150
300
204.0
1
1
NIL
HORIZONTAL

SLIDER
668
131
876
164
yellow-min-income-level
yellow-min-income-level
100
150
100.0
1
1
NIL
HORIZONTAL

SLIDER
873
164
1082
197
green-max-income-level
green-max-income-level
100
400
156.0
1
1
NIL
HORIZONTAL

SLIDER
668
164
873
197
green-min-income-level
green-min-income-level
0
100
79.0
1
1
NIL
HORIZONTAL

SLIDER
858
35
1052
68
red-max-income-level
red-max-income-level
0
100
54.0
1
1
NIL
HORIZONTAL

PLOT
663
267
863
417
average-color-similarity
time
NIL
0.0
25.0
0.0
1.0
true
true
"" ""
PENS
"percent" 1.0 0 -16777216 true "" "plot average-color-similarity"

SLIDER
8
164
185
197
similarity-threshold
similarity-threshold
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
8
197
180
230
num-steps
num-steps
1
10
10.0
1
1
NIL
HORIZONTAL

MONITOR
665
222
832
267
 average-color-similarity
average-color-similarity
17
1
11

MONITOR
864
223
1041
268
average-income-similarity
average-income-similarity
20
1
11

PLOT
863
267
1063
417
average-income-similarity
time
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-income-similarity"

TEXTBOX
10
79
224
107
Adjust consumption differences
12
95.0
1

TEXTBOX
6
237
156
255
Adjust population ratio
12
125.0
1

TEXTBOX
676
12
884
42
Adjust income distribution
12
75.0
1

PLOT
865
437
1065
587
color-similarity/income-similarity
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [color-similarity]  of turtles)/( sum [income-similarity] of turtles)"

PLOT
662
437
862
587
percent unhappy
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -16777216 true "" "plot percent-unhappy "

@#$#@#$#@
## WHAT IS IT?

(The purpose of this model is to simulate the impact of economic levels on racial residential segregation. By simulating the income levels and living expenses of different racial groups, as well as their housing choices in environments with different consumption levels, the model aims to address the following two questions:
•	Q1: Does the income gap between races lead to racial residential segregation?
•	Q2: How can adjusting income distribution or living costs influence the degree of racial segregation?
)

## HOW IT WORKS

(•	Turtle Behavior: Turtles are randomly assigned to a patch. If a turtle's income is lower than the local consumption level, it cannot survive in that area and needs to move to a different environment. If a turtle's income is more than double the local consumption level, it is deemed unsuitable for the environment and must relocate. Turtles are considered happy if their income is between the local consumption level and twice the local consumption level. The model runs until all turtles are satisfied and stop moving.
•	Environmental Changes: To better simulate real-world environments, the consumption level of an area changes based on the income levels of the inhabitants. If the residents' income is high, the area's consumption level increases. Conversely, if the residents' income is low, the area's consumption level decreases.
•	Statistical Data Collection: Individuals interact with their neighbors to calculate color similarity, income similarity, and consumption level similarity.
)

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
NetLogo 6.4.0
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
