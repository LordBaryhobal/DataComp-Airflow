#import "@preview/touying:0.6.1": *
#import themes.simple: *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.8": codly-languages

#set document(
  author: "Louis Heredero",
  title: "Apache Airflow Custom Providers",
  date: datetime.today()
)

#set text(
  font: "Source Sans 3"
)

#show link: set text(fill: blue)

#show: codly-init
#codly(
  languages: codly-languages
)

#show: simple-theme.with(
  footer: [Apache Airflow - Custom Providers]
)

#title-slide[
  #image("logo.png", width: 8cm)
  #text(size: 1.2em, weight: "bold")[Custom Providers]
  
  #v(2cm)

  #text(
    size: 0.8em,
    fill: gray.darken(30%)
  )[_by Louis Heredero_]
]

== Modularity

Apache Airflow is very powerful thanks to its modularity

Small components which communicate between each other

- Operations
- Notifications
- Transfers
- Secret backends
- Logs
- And more

== Operators

#let dag(hl: false) = canvas({
  let green1 = rgb("edffe2")
  let green2 = rgb("008000")
  let task(pos, id, name, op, ..args) = {
    let body = stack(
      dir: ttb,
      spacing: .4em,
      text(weight: "bold", name),
      grid(
        columns: 2,
        align: horizon,
        gutter: .4em,
        rect(fill: green2, width: .5em, height: .5em, radius: .1em),
        text(fill: gray, baseline: -2pt)[success]
      ),
      text(fill: if hl {red} else {gray}, op)
    )
    draw.content(
      pos,
      body,
      padding: (x: .6em, y: .4em),
      fill: red,
      name: id,
      ..args
    )
    draw.on-layer(-1, {
      draw.rect(
        id + ".north-west",
        id + ".south-east",
        radius: .2em,
        fill: green1,
        stroke: green2
      )
    })
  }

  let link = draw.line.with(stroke: gray.darken(50%))

  task(
    (0, 0),
    "a"
  )[dl_dataset][BashOperator]
  task(
    (rel: (1, .5), to: "a.east"),
    "c",
    anchor: "west"
  )[extract_info][DockerOperator]
  link("c.west", ((), "-|", "a.east"))
  task(
    (rel: (0, -1), to: "c.south"),
    "b",
    anchor: "north"
  )[convert][BashOperator]
  link(
    ("a.south-east", 1, "a.north-east"),
    (rel: (0.5, 0)),
    ((), "|-", "b.west"),
    "b.west"
  )
  task(
    (rel: (1, -.5), to: "c.east"),
    "d",
    anchor: "west"
  )[combine][PythonOperator]
  link("c.east", ((), "-|", "d.west"))
  link(
    ("d.south-west", 1, "d.north-west"),
    (rel: (-0.5, 0)),
    ((), "|-", "b.east"),
    "b.east",
  )
})

#v(1cm)

#place(
  center,
  alternatives(
    dag(),
    stack(
      dir: ttb,
      spacing: 2em,
      dag(hl: true),
      [Operators are defined by *providers*]
    )
  )
)

== Notifiers

#let cetz-canvas = touying-reducer.with(
  reduce: canvas,
  cover: draw.hide.with(bounds: true)
)

#columns(2)[
  Triggered by events (`*_callback`):
  - success // Invoked when a task or DAG succeeds.
  - failure // Invoked when a task or DAG fails.
  - skipped // Invoked when a task is skipped.
  - execute (before) // Invoked right before a task begins executing.
  - retry // Invoked when a task is retried.
  - ...
  #colbreak()
  #align(
    horizon,
    cetz-canvas({
      let endpoints = ([Email], [Discord], [Slack], [Teams], [*Minecraft ?*])
      for (i, endpoint) in endpoints.enumerate() {
        (pause,)
        let y = (endpoints.len() - 1) / 2 - i
        draw.content(
          (2, y * 1.5),
          anchor: "west",
          name: "ep-" + str(i),
          padding: (x: .4em),
          endpoint
        )
        draw.line(
          (0, 0),
          "ep-" + str(i) + ".west",
          mark: (end: ">", fill: black)
        )
      }
    })
  )
]

== Implementation

A provider is defined as a Python package

#codly(
  header: [`pyproject.toml`],
  smart-skip: true,
  ranges: ((1, 7), (13, 14))
)
#text(
  size: .6em,
  raw(
    block: true,
    lang: "toml",
    read("../plugins_dev/mc-notifier/pyproject.toml")
  )
)

---

#codly(
  header: [`__init__.py`],
  smart-skip: true,
  ranges: ((3, 7), (15, 29))
)
#text(
  size: .35em,
  raw(
    block: true,
    lang: "python",
    read("../plugins_dev/mc-notifier/minecraft_provider/__init__.py")
  )
)

---

#codly(
  smart-skip: false,
  header: [`hooks/rcon.py`],
  range: (8, 72)
)
#columns(
  2,
  text(
    size: .3em,
    raw(
      block: true,
      lang: "python",
      read("../plugins_dev/mc-notifier/minecraft_provider/hooks/rcon.py")
    )
  )
)

---

#codly(
  smart-skip: false,
  header: [`notifications/minecraft.py`],
  range: (7, 35)
)
#columns(
  2,
  text(
    size: .48em,
    raw(
      block: true,
      lang: "python",
      read("../plugins_dev/mc-notifier/minecraft_provider/notifications/minecraft.py")
    )
  )
)

== Using our provider

1. Install it in our docker container
2. Import it in a DAG file
3. Use the notifier as a callback

#columns(
  2,
  text(
    size: .38em,
    raw(
      block: true,
      lang: "python",
      read("../dags/minecraft_test.py")
    )
  )
)

4. Create a connection in the Web UI

#align(
  center + horizon,
  image("new_connection.png", height: 80%)
)

5. Run the DAG

#align(
  center + horizon,
  image("notification.png", height: 80%)
)

== References

- Apache Airflow tutorial:\
  https://airflow.apache.org/docs/apache-airflow-providers/howto/create-custom-providers.html

- Astronomer example provider:\
  https://github.com/astronomer/airflow-provider-sample

- Minecraft RCON protocol:\
  https://minecraft.wiki/w/RCON