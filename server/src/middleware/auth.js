import jwt from 'jsonwebtoken';

export function requireAuth(roles = []) {
  return (req, res, next) => {
    const token = (req.header('Authorization') || '').replace('Bearer ', '');
    try {
      const user = jwt.verify(token, process.env.JWT_SECRET);
      if (roles.length && !roles.includes(user.rol))
        return res.status(403).json({ error: 'Sin permiso' });
      req.user = user;
      next();
    } catch {
      res.status(401).json({ error: 'No autenticado' });
    }
  };
}
