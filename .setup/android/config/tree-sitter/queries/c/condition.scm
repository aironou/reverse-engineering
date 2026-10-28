; if (user != NULL) {
;     authenticate(user);
; }
;
; switch (status) {
;     case 1:
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

(switch_statement
  condition: (_) @condition.expression
  body: (_) @condition.body) @condition

(conditional_expression
  condition: (_) @condition.expression
  consequence: (_) @condition.consequence
  alternative: (_) @condition.alternative) @condition