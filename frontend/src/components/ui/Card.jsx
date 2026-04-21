import clsx from 'clsx';

export function Card({ children, className, ...props }) {
  return (
    <div className={clsx('bg-white border border-slate-200 rounded-xl shadow-sm p-6', className)} {...props}>
      {children}
    </div>
  );
}
