{% macro discounted_price(extended_price, discount) %}
    ({{ extended_price }} * (1 - {{ discount }}))
{% endmacro %}

{% macro price_after_tax(price, tax_rate) %}
    ({{ price }} * (1 + {{ tax_rate }}))
{% endmacro %}
