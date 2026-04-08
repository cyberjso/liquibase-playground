INSERT INTO lab.work_items (title, status)
VALUES
    ('Design login page', 'OPEN'),
    ('Implement auth API', 'IN_PROGRESS'),
    ('Fix regression in billing', 'OPEN');

INSERT INTO lab.labels (label_key, description)
VALUES
    ('frontend', 'UI and UX related work'),
    ('backend', 'API and service work'),
    ('urgent', 'Requires priority handling')
ON CONFLICT (label_key) DO NOTHING;

CALL lab.sp_apply_label_to_item(1000, 'frontend');
CALL lab.sp_apply_label_to_item(1001, 'backend');
CALL lab.sp_apply_label_to_item(1002, 'urgent');
