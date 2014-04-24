console = window.console

RAILS = 

  initialized: false
          
  clean: (callback) ->
    console.log 'Operating cleaning...'
    if RAILS.window.INITialized or false
      Gibberish.clear()
    callback()

  init: (callback) ->
    console.log 'window.INITializing Gibberails audio-client...'
    try 
      Gibberish.window.INIT()
      Gibberish.Time.export()
      Gibberish.Binops.export()
      if callback then callback()
    catch e
      alert e  
  
  execute: (compile, data, callback) ->
    try
      js = unescape(data)
      js = compile js, bare:true, map:{}
      js = unescape js
      if callback then callback !js, js
    catch e
      RAILS.window.INITialized = false
      alert "#{compile.prototype.name}:\n#{js.map}#{e}"
      
  run: (callback)->
    console.log 'Operating compilation...'
    RAILS.execute CoffeeScript.compile, RAILS.editor.getValue(), (err, js) ->
      if callback then callback err, eval js else eval js

  checkfloats: (k, v)->
    b = false
    for t in ['freq', 'amp', 'pulsewidth', 'chance', 'pitchMin', 'pitchMax', 'pitchChance', 'cutoff', 'Q', 'roomSize', 'dry', 'wet']
      if (typeof(v) is 'object') and k == t
        b = true
        break
    b
  
  checkints: (k, v)->
    b = false
    for t in ['mode', 'rate', 'amount']
      if (typeof(v) is 'object') and k == t
        b = true
        break
    b
    
# As funções abaixo são apenas para serem utilizadas
# dentro do ambiente dado pela função `eval()` durante
# o processo do JIT
  
# Após inicializar, limpe, re-inicie o servidor de audio e execute a função
# dada pelo usuario depois de um tempo determinado
window.INIT = (time, callback) -> 
  setTimeout -> RAILS.clean -> RAILS.init ->
    console.log "! RUnNINg !"
    RAILS.initialized = true
    callback() 
  , time

# Um gerador de audio
# ```coffee
# sinG = new Gibberish.Sine(445, 0.71)
# sin = window.GEN "Sine", amp:440, freq: 0.71 # similar ao anterior
# sinG.connect()  
# sin.connect()
# ```
# _return_ *Gibberish.Ugen*
window.GEN = (n, o, c) ->
  try
    u = new Gibberish[n]
    console.log "#{u} #{n}:"
    (console.log "  #{k}:#{v}" ; u[k] = v) for k, v of o
    if c then c u else u
  catch e
    alert e

# Um gerador de audio, mas com valores randomicos; é interessante notar que
# se você quiser um número randômico, forneça um Array de dois valores; se você
# não quiser, deixe como quiser
# ```coffee
# sinG = new Gibberish.Sine(Gibberish.rndf(440, 445), 0.71)
# sin = GEN_RANDOM "Sine", amp: 0.71, freq: [440, 445] # similar ao anterior
# sinG.connect()  
# sin.connect()
# ```
# _return_ *Gibberish.Ugen*  
window.GEN_RAND = (n, o, c) ->
  for k, v of o
    if RAILS.checkfloats(k, v)
      o[k] = Gibberish.rndf v[0], v[v.length-1] 
    else if RAILS.checkints(k, v)
      o[k] = Gibberish.rndi v[0], v[v.length-1]
    else
      o[k] = v     
  window.GEN n, o, c

# Um gerador de audio, mas com valores dados por uma função; é interessante notar que
# se você quiser um número algoritico, forneça uma função geradora que retorne um
# objeto (Hash) com as propriedades necessárias para a Unidade geradora de audio; se você
# não quiser, deixe como quiser
# ```coffee
# freq = Gibberish.rndf(440, 445)
# amp = 1/o.freq 
# sinG = new Gibberish.Sine(freq, amp)
# sin = GEN_FN "Sine", freq: -> Gibberish.rndf(440, 445), amp: (freq)-> 1/freq
# sinG.connect()  
# sin.connect()
# ```
# _return_ *Gibberish.Ugen*   
window.GEN_FN = (n, o, c) ->
  for k, v of o
    if (typeof(v) is 'Function') 
      o[k] = v()
  window.GEN n, o, c

# Um simples sequenciador, onde se passa funções geradoras de arrays;
# Aqui se nota um processo de composição algoritimica, onde passsa-se qualquer
# função geradora de uma série de valores numericos
# ```coffee
# GEN_SEQ 
#   target: karplus
#   durations: ->
#     min = Gibberish.rndi(30, 500)
#     max = Gibberish.rndi(970, 1100)
#     [ms(min)..ms(max)]
#   keysAndValues:
#     note: ->
#       a = []
#       a[i] = Math.pow(2, i+8) for i in [0..7]
#       a[Gibberish.rndi(0, a.length-1)] for i in [0..21]
#     amp: ->
#       a = []
#       a[i] = Math.pow(2, i+8) for i in [0..7]
#       a[Gibberish.rndi(0, a.length-1)]/16384 for i in [0..13]
# ```
# _return_ *Gibberish.Sequencer*
window.GEN_SEQ = (o, c) ->
  o.keysAndValues[k] = v() for k, v of o.keysAndValues 
  o.durations = o.durations()
  u = new Gibberish.Sequencer(o)
  if c then c u else u