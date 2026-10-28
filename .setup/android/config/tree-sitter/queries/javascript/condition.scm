; if (user) {
;     authenticate(user);
; } else {
;     reject();
; }
;
; switch (status) {
;     case "active":
;         enable();
;         break;
;     default:
;         disable();
; }
;
; const port = secure ? 443 : 80;

(if_statement
  condition: (_) @condition.expression
  consequence: (_) @condition.consequence
  alternative: (_)? @condition.alternative) @condition

(switch_statement
  value: (_) @condition.expression
  body: (_) @condition.body) @condition

(ternary_expression
  condition: (_) @condition.expression
  consequence: (_) @condition.consequence
  alternative: (_) @condition.alternative) @condition