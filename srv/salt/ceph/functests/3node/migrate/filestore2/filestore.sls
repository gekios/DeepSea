
{% set node = salt.saltutil.runner('select.first', roles='storage') %}
{% set label = "f2tof" %}

Check environment {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.check3
    - failhard: True

Update destroyed for reset {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.update_destroyed
    - tgt_type: compound

Remove OSDs {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.remove_osds
    - failhard: True
       
Remove destroyed {{ label }}:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.remove.destroyed
    - failhard: True

Initialize OSDs {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.init_osds
    - pillar: {{ salt.saltutil.runner('smoketests.pillar', minion=node, configuration='filestore2') }}
    - failhard: True
       
Save reset checklist {{ label }}:
  salt.runner:
    - name: smoketests.checklist
    - minion: {{ node }}
    - configuration: 'filestore2'

Check reset OSDs {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.check_osds
    - pillar: {{ salt.saltutil.runner('smoketests.pillar', minion=node, configuration='filestore2') }}
    - failhard: True

Update destroyed for migrate {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.update_destroyed
    - tgt_type: compound

Migrate {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.redeploy.osds
    - pillar: {{ salt.saltutil.runner('smoketests.pillar', minion=node, configuration='filestore') }}
    - failhard: True

Save checklist {{ label }}:
  salt.runner:
    - name: smoketests.checklist
    - minion: {{ node }}
    - configuration: 'filestore'

Check OSDs {{ label }}:
  salt.state:
    - tgt: {{ node }}
    - sls: ceph.tests.migrate.check_osds
    - pillar: {{ salt.saltutil.runner('smoketests.pillar', minion=node, configuration='filestore') }}
    - failhard: True