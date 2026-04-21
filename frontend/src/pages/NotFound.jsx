import { Link } from 'react-router-dom';

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center text-center p-6">
      <h1 className="text-6xl font-bold text-primary-600">404</h1>
      <p className="text-xl text-slate-600 mt-2">Səhifə tapılmadı</p>
      <Link to="/" className="mt-4 text-primary-600 hover:underline">Ana səhifəyə qayıt</Link>
    </div>
  );
}
