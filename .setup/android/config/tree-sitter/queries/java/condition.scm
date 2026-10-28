; if (user != null) {
;     authenticate(user);
; } else {
;     reject();
; }
;
; switch (status) {
;     case ACTIVE:
;         enable();
;         break;
;     default:
;         disable();
; }
;
; int port = secure ? 443 : 80;

(if_statement
  condition: (_) @condition.expression
  consequence: (_) @condition.consequence
  alternative: (_)? @condition.alternative) @condition

(switch_expression
  condition: (_) @condition.expression
  body: (_) @condition.body) @condition

(ternary_expression
  condition: (_) @condition.expression
  consequence: (_) @condition.consequence
  alternative: (_) @condition.alternative) @condition