import efetch
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}
import gleam/http/request
import gleam/io
import gleam/list
import gleam/result.{try}

pub fn make_request(url: String) -> Result(String, efetch.HttpError) {
  let assert Ok(request) = request.to(url)
  io.debug(url)

  use response <- try(
    request
    |> request.prepend_header("accept", "application/json")
    |> efetch.send,
  )
  Ok(response.body)
}

pub type RequestParameter {
  RequestParameter(key: String, value: String)
}

pub fn get_final_url(
  base_url: String,
  prefix: String,
  commercial: Bool,
  endpoint: String,
  apikey: String,
  params: List(RequestParameter),
) {
  "https://"
  <> case commercial {
    True -> "customer-"
    False -> ""
  }
  <> case prefix {
    "" -> ""
    _ -> prefix <> "-"
  }
  <> base_url
  <> endpoint
  <> "?"
  <> list.fold(params, "", fn(a, b) { a <> b.key <> "=" <> b.value <> "&" })
  <> case commercial {
    True -> "apikey" <> "=" <> apikey
    False -> ""
  }
}

// Taken from https://github.com/gleam-lang/stdlib/blob/v0.39.0/src/gleam/dynamic.gleam#L1530
fn all_errors(result: Result(a, List(DecodeError))) -> List(DecodeError) {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}

// Adapted from gleam/dynamic source code
pub fn decode18(
  constructor: fn(
    t1,
    t2,
    t3,
    t4,
    t5,
    t6,
    t7,
    t8,
    t9,
    t10,
    t11,
    t12,
    t13,
    t14,
    t15,
    t16,
    t17,
    t18,
  ) ->
    t,
  t1: Decoder(t1),
  t2: Decoder(t2),
  t3: Decoder(t3),
  t4: Decoder(t4),
  t5: Decoder(t5),
  t6: Decoder(t6),
  t7: Decoder(t7),
  t8: Decoder(t8),
  t9: Decoder(t9),
  t10: Decoder(t10),
  t11: Decoder(t11),
  t12: Decoder(t12),
  t13: Decoder(t13),
  t14: Decoder(t14),
  t15: Decoder(t15),
  t16: Decoder(t16),
  t17: Decoder(t17),
  t18: Decoder(t18),
) -> Decoder(t) {
  fn(x: Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x),
      t12(x),
      t13(x),
      t14(x),
      t15(x),
      t16(x),
      t17(x),
      t18(x)
    {
      Ok(a),
        Ok(b),
        Ok(c),
        Ok(d),
        Ok(e),
        Ok(f),
        Ok(g),
        Ok(h),
        Ok(i),
        Ok(j),
        Ok(k),
        Ok(l),
        Ok(m),
        Ok(n),
        Ok(o),
        Ok(p),
        Ok(q),
        Ok(r)
      -> Ok(constructor(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r))
      a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
            all_errors(l),
            all_errors(m),
            all_errors(n),
            all_errors(o),
            all_errors(p),
            all_errors(q),
            all_errors(r),
          ]),
        )
    }
  }
}
