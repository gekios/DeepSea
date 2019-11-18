
storage nop:
  test.nop

{% if 'storage' not in salt['pillar.get']('roles') %}

stop osd.target:
  service.dead:
    - name: ceph-osd.target
    - enable: False

{% for id in salt['osd.list']() %}

removing {{ id }}:
  module.run:
    - name: osd.remove
    - osd_id: {{ id }}
    - kwargs:
        force: True

{% endfor %}

include:
- .keyring
{% endif %}
