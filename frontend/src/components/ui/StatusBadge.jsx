import clsx from 'clsx';

const config = {
  planned:     { label: 'Planlaşdırılıb', cls: 'bg-slate-100 text-slate-700' },
  approved:    { label: 'Təsdiqlənib',   cls: 'bg-blue-100 text-blue-700' },
  in_progress: { label: 'İcrada',        cls: 'bg-amber-100 text-amber-700' },
  suspended:   { label: 'Dayandırılıb',  cls: 'bg-orange-100 text-orange-700' },
  completed:   { label: 'Tamamlanıb',    cls: 'bg-green-100 text-green-700' },
  cancelled:   { label: 'Ləğv',          cls: 'bg-red-100 text-red-700' },
};

export function StatusBadge({ status }) {
  const c = config[status] || config.planned;
  return (
    <span className={clsx('inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium', c.cls)}>
      {c.label}
    </span>
  );
}
