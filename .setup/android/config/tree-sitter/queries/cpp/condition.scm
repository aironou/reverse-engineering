; if (service.isReady()) {
;     service.connect();
; } else {
;     service.reset();
; }
;
; switch (status) {
;     case Status::Ready:
;         connect();
;         break;
;     default:
;         reset();
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