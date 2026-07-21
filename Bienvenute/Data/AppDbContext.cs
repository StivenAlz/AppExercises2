using Bienvenute.Models;
using Microsoft.EntityFrameworkCore;

namespace Bienvenute.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Saludo> Saludos { get; set; }
}