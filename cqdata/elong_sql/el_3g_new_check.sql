--����3G�ֻ���(20120922-20121031)
--�����ֻ��嵥(ֻȡ����)   --���˽ű�
--���ֿھ�: 1.�û���Ŀ������ڴ���20120922-20121031
--2.��������ʦ�Ŀ����������п������ڴ�������ʱ���
/* ϣ���ܹ���ȡ���ֶ�:
����	�ֻ�����	����	����	�ֻ���	�ʷ�	����	����	������	������	��ע
*/

--���˱���: tmp_el_3g_new_AREA_FEEMONTH
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select '' id,a.* from tmp_el_3g_new_AREA_FEEMONTH a limit 0 distributed by (acc_nbr); 
-- ����������9��22����ǰ���嵥,���ֻ��ڱ�־��, ��Ҫ������ȷ�ϲ��μ��ֻ���.
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values ('����ʱ����9��22����ǰ��,��Ҫ������ȷ�ϲ��μ��ֻ���');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '1����ʱ����9��21����ǰ��',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����ʱ��<'2012-09-22 00:00:00' and �ֻ��� is null and ��������>='2012-09-22 00:00:00';
-- ����������9��22����ǰ���嵥,�ֻ��ڱ�־��, ��Ҫȷ���ն�����ʱ����9��22�ռ��Ժ�.

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (9);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (10, '����ʱ����9��22����ǰ���д����,��Ҫ������ȷ�ϴ�������ʱ����9��22�ռ��Ժ�');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '2����ʱ����9.22ǰ���д����',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����ʱ��<'2012-09-22 00:00:00' and �ֻ��� is not null and ��������>='2012-09-22 00:00:00' and  serv_state='2HA';

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (19);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (20, 'û��¼�����,�Ƿ�Ϊ�û������뻧,���Ǵ��������۷��ֻ��ڵ����?');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '3û��¼�����',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����ʱ��>='2012-09-22 00:00:00' and (����='\\' or ���� is null) and ��������>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (30);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (31, '¼�˴���û��¼�ֻ��ڱ�־,ȷ��?');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '4�д������ֻ��ڴ���',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����ʱ��>='2012-09-22 00:00:00' and not (����='\\' or ���� is null) and �ֻ��� is null and ��������>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (40);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (41, 'δ¼�������¼�ֻ��ڱ�־,Ӧ�д�');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '5δ¼��������ֻ��ڱ�־',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����ʱ��>='2012-09-22 00:00:00' and (����='\\' or ���� is null) and �ֻ��� is not null and ��������>='2012-09-22 00:00:00' and serv_state='2HA';

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (50);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (51, '������Ϊ��, ����Ǽ�װ�ֻ�ֻ¼�˼�װ��,û��¼������');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '6������Ϊ��,�϶��д�',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ������ is  null and ��������>='2012-09-22 00:00:00'  and serv_state='2HA';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '65δ������̻��ϻ�,�����ѷ�ʽΪ�󸶷ѵ�',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ad�ӹ̻�����=0 and 
����ģʽ=1 and serv_state='2HA' 
and ��������>='2012-10-25 00:00:00'
;

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (60);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (61, '�����־Ϊ0, ���ԭ����');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '7�����ͣ����',a.* from tmp_el_3g_new_AREA_FEEMONTH a where remove_date<'2030-12-31' and ��������>='2012-09-22 00:00:00'  and serv_state<>'2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (70);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (71, '����Ϊ��,�������������ò���');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '8����Ϊ��',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ����Ա�� is null  and ��������>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (80);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (81, '������δѡ���ε�');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '90������δѡ����',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ������ like '%%���������ײ�%%' and �������������� is null and ��������>='2012-09-22 00:00:00' and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (90);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, ��������) values (91, '������δ�ͻ��ѵ�,ȷ��');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '91������δ�ͻ���',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ������ like '%%���������ײ�%%' and �ͻ��� is null and ��������>='2012-09-22 00:00:00' and serv_state='2HA';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '92������ܻ���δ��100M������',a.* from tmp_el_3g_new_AREA_FEEMONTH a where �ֻ��� like '%%���ܻ�%%' and ������ is null and ��������>='2012-09-22 00:00:00' and serv_state='2HA';

-- ���ͷ�̷��������, ����һ��: ��ͬ�Ž���ʱ�������ֻ���, ���������Ϻ�ͬ�ŵ�
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '93���ɲ������Ϻ�ͬ�ŵ�',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ��ͬ�Ž���ʱ��<'2012-09-22 00:00:00' and ��������>='2012-09-22 00:00:00' and serv_state='2HA';

select '33';
