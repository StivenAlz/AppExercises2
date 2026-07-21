using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pokerface.Data;

namespace Pokerface.Controllers;

[ApiController]
[Route("[controller]")]
public class AdivinanzasController : ControllerBase
{
    private readonly AppDbContext _context;

    public AdivinanzasController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var adivinanza = await _context.Adivinanzas
            .OrderBy(r => EF.Functions.Random())
            .FirstOrDefaultAsync();

        if (adivinanza == null)
            return NotFound("No hay adivinanzas disponibles.");

        return Ok(new
        {
            mensaje = "🧠 ¡Adivina, adivinador!",
            adivinanza = adivinanza.Texto
        });
    }
}