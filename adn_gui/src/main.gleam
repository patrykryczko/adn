import ffi/tauri
import gleam/io
import gleam/javascript/promise
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute as attr
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() {
  lustre.application(init, update, view)
  |> lustre.start("#app", Nil)
  |> handle_error
}

fn handle_error(v: Result(a, lustre.Error)) -> Nil {
  case v {
    Error(lustre.ActorError(_)) ->
      io.println_error("Actor error while initialising Lustre.")

    Error(lustre.BadComponentName(name)) ->
      io.println_error("Bad component name: " <> name)

    Error(lustre.ComponentAlreadyRegistered(name)) ->
      io.println_error("Component already registered: " <> name)

    Error(lustre.ElementNotFound(selector)) ->
      io.println_error("Selector not found: " <> selector)

    Error(lustre.NotABrowser) ->
      io.println_error("Expected to be running a browser.")

    Ok(_) -> Nil
  }
}

// -- Model
type Model {
  Model(name: String, greeting: Option(String))
}

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model("", None), effect.none())
}

pub type Msg {
  UpdateName(String)
  UpdateGreeting(String)
  SubmitName
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UpdateName(name) -> #(Model(..model, name: name), effect.none())
    UpdateGreeting(greeting) -> #(
      Model(..model, greeting: Some(greeting)),
      effect.none(),
    )
    SubmitName -> #(model, effect.from(get_greeting(model.name)))
  }
}

fn get_greeting(name: String) {
  fn(dispatch) {
    tauri.greet(name)
    |> promise.map(fn(greeting) { dispatch(UpdateGreeting(greeting)) })

    Nil
  }
}

// -- VIEW

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("Gleam + Vite + Tauri")]),
    html.div([attr.class("field text-center")], [
      html.label([attr.for("greet_name")], [element.text("Name")]),
      element.text(" "),
      html.input([
        attr.type_("text"),
        attr.name("greet_name"),
        event.on_input(UpdateName),
      ]),
      html.button(
        [
          attr.class(
            "rounded-lg border border-transparent py-2.5 px-5 font-medium",
          ),
          event.on_click(SubmitName),
        ],
        [element.text("Greet")],
      ),
    ]),
    html.p(
      [attr.class("text-center")],
      model.greeting
        |> option.map(fn(g) { [element.text(g)] })
        |> option.unwrap([]),
    ),
  ])
}
