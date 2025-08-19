---
- name: Apache HTTP Server web server deployment
  hosts: httpd
  become: true

  roles:
    - name: redhat.rhel_system_roles.selinux
      selinux_fcontexts:
        - target: "{{ selinux_target }}"
          setype: "{{ selinux_setype }}"
          state: present

  tasks:
    - name: Latest software installed for Apache HTTPD
      ansible.builtin.dnf:
        name: "{{ httpd_packages }}"
        state: present

    - name: Web content is in place
      ansible.builtin.import_tasks: deploy_content.yml

    - name: Virtual hosts are configured
      ansible.builtin.template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf.d/{{ item }}.conf"
      loop: "{{ web_hosts }}"

    - name: Firewall ports are open
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - https
        - http

    - name: Web server is started and enabled
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
