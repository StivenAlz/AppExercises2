using Microsoft.EntityFrameworkCore;
using Pokerface.Models;

namespace Pokerface.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Adivinanza> Adivinanzas { get; set; }
    public DbSet<Chiste> Chistes { get; set; }
}