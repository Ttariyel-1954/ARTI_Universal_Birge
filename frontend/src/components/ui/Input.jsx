import { forwardRef } from 'react';
import clsx from 'clsx';

export const Input = forwardRef(({ label, error, className, ...props }, ref) => (
  <div className="space-y-1">
    {label && <label className="block text-sm font-medium text-slate-700">{label}</label>}
    <input
      ref={ref}
      className={clsx(
        'w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent',
        error ? 'border-red-400' : 'border-slate-300',
        className
      )}
      {...props}
    />
    {error && <p className="text-sm text-red-600">{error}</p>}
  </div>
));
Input.displayName = 'Input';
